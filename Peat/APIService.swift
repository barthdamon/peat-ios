//
//  APIService.swift
//  Peat
//
//  Created by Matthew Barth on 9/10/15.
//  Copyright (c) 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

typealias APICallback = ((AnyObject?, NSError?) -> ())

enum HTTPRequestAuthType: String {
  case Basic = ""
  case Token = "token/"
}

//// our singleton
private let _sharedService = APIService()

class APIService: NSObject {
  
  // if we are running on a device use the production server
  #if (arch(i386) || arch(x86_64)) && os(iOS)
  //     DEVELOPMENT
  let baseURL = "http://localhost:3000"
  #else
  // PRODUCTION
  let baseURL = "http://localhost:3000"
  #endif
  
    var authToken: String? {
      return CurrentUser.info.token()
    }
    var apiURL: String { return "\(baseURL)/" }
    private let api_pw = "fartpoop"
  
    class var sharedService: APIService {
      return _sharedService
    }
  
  func get(params: [ String : AnyObject ]?, authType: HTTPRequestAuthType = .Token, url: String, callback: APICallback) {
    request("GET", params: params, authType: authType, url: url, callback: callback)
  }
  
  func post(params: [ String : AnyObject ]?, authType: HTTPRequestAuthType = .Token, url: String, callback: APICallback) {
    request("POST", params: params, authType: authType, url: url, callback: callback)
  }
  
  func put(params: [ String : AnyObject ]?, authType: HTTPRequestAuthType = .Token, url: String, callback: APICallback) {
    request("PUT", params: params, authType: authType, url: url, callback: callback)
  }
  
  func delete(params: [ String : AnyObject ]?, authType: HTTPRequestAuthType = .Token, url: String, callback: APICallback) {
    request("DELETE", params: params, authType: authType, url: url, callback: callback)
  }
  
  //MARK: Private Methods
  private func request(type: String, params: [ String : AnyObject ]?, authType: HTTPRequestAuthType, url: String, callback: APICallback) {
    let request = NSMutableURLRequest(URL: NSURL(string: apiURL + authType.rawValue + url)!)
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = type
    
    var err: NSError?
    
    if let parameters = params {
      do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
      } catch let error as NSError {
        err = error
        print(err)
        request.HTTPBody = nil
      }
    }
    
    //MARK: Standard Headers:
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(NSLocale.currentLocale().localeIdentifier, forHTTPHeaderField: "Accept-Language")
    request.addValue(api_pw, forHTTPHeaderField: "api_auth_password")
    
    //MARK: Auth Specific Headers:
    switch authType {
    case .Basic:
      request.addValue("Basic", forHTTPHeaderField: "auth_type")
      //add username and password params to body
    case .Token:
      if let token = authToken {
        request.addValue("Token", forHTTPHeaderField: "auth_type")
        request.addValue(token, forHTTPHeaderField: "token")
      }
    }
    
    let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
      
      if (error != nil) {
        print("Error making request to \(url)")
        callback(nil, error)
      }
      
      if let res = response as! NSHTTPURLResponse! {
        //Use this notification for when user makes any request but gets unauthorized, means token is expired, send them back to login
//        if res.statusCode == 401 { // unauthorized
//          print("Error server responded with 401: Unauthorized")
//          NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "errorUnauthorizedNotification", object: nil))
//        }
        if res.statusCode != 200 && res.statusCode != 201 {
          print("Error, server responded with: \(res.statusCode) to request for \(url)" )
          let errorMessage = self.parseError(data!)
          let e = NSError(domain: "SRP", code: 100, userInfo: [ "statusCode": res.statusCode, "message" : errorMessage ])
          callback(nil, e)
          return
        }
        self.parseData(data!, callback: callback)
      } else {
        print("Server Not Responding")
      }
    })
    
    task.resume()
  }
  
  
  // assuming the server returns an error message in the format "message" : <the error message>
  // this method returns the message string or "undefined"
  private func parseError(data: NSData) -> String {
    
    var serializationError: NSError?
    var json: AnyObject?
    do {
      json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
    } catch let error as NSError {
      serializationError = error
      json = nil
    }
    
    if(serializationError != nil) {
      return "undefined"
    } else {
      if let jsonMessage = json {
        if let message = jsonMessage["message"] as? String {
          return message
        } else {
          if let message = jsonMessage["emails.address"] as? Array<String> {
            print("Email \(message[0])")
            return "Email \(message[0])"
          }
        }
        
      }
      return "undefined"
    }
  }
  
  private func parseData(data: NSData, callback: APICallback) {
    var serializationError: NSError?
    
    var json: AnyObject?
      do {
        json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
      } catch let error as NSError {
        serializationError = error
        json = nil
      }
    
    if(serializationError != nil) {
      callback(nil, serializationError)
    }
    else {
      if let parsedJSON: AnyObject = json {
        print("RESPONSE: \(parsedJSON)")
        callback(parsedJSON, nil)
      }
      else {
        let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
        print("Error could not parse JSON: \(jsonStr)")
        let e = NSError(domain: "Oddworks", code: 101, userInfo: [ "JSON" : jsonStr ])
        callback(nil, e)
      }
    }
  }
  
}
