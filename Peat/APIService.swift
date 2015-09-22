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

//// our singleton
private let _sharedService = APIService()

class APIService: NSObject {
  
  // if we are running on a device use the production server
  #if (arch(i386) || arch(x86_64)) && os(iOS)
  //     DEVELOPMENT
  let baseURL = "http://localhost:3000"
  #else
  // PRODUCTION
  let baseURL = "https://device.oddworks.io"
  #endif
  
    var apiURL: String { return "\(baseURL)/" }
//  let authToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ2ZXJzaW9uIjoxLCJkZXZpY2VJRCI6ImMxMDMwZjNiLTMxOTctNDA4ZS04ODY4LTliM2Q2MDE4MDkyNyIsInNjb3BlIjpbImRldmljZSJdLCJpYXQiOjE0Mzk5Mjg3MjF9.Hx_st7FnU_jJJQ5YJLCbtzWBNhHR53a4s1KIWvEmhio"
  
    class var sharedService: APIService {
      return _sharedService
    }
  
  func get(params: [ String : String ]?, url: String, callback: APICallback) {
    request("GET", params: params, url: url, callback: callback)
  }
  
  func post(params: [ String : AnyObject ]?, headers: [ String : String]?, url: String, callback: APICallback) {
    request("POST", params: params, url: url, callback: callback)
  }
  
  func put(params: [ String : String ]?, url: String, callback: APICallback) {
    request("PUT", params: params, url: url, callback: callback)
  }
  
  func delete(params: [ String : String ]?, url: String, callback: APICallback) {
    request("DELETE", params: params, url: url, callback: callback)
  }
  
  //MARK: Private Methods
  private func request(type: String, params: [ String : AnyObject ]?, url: String, callback: APICallback) {
    let request = NSMutableURLRequest(URL: NSURL(string: apiURL + url)!)
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
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    request.addValue(NSLocale.currentLocale().localeIdentifier, forHTTPHeaderField: "Accept-Language")
    
    request.addValue("matt", forHTTPHeaderField: "api_authtoken")
    request.addValue("fartpoop", forHTTPHeaderField: "api_auth_password")
//    request.addValue(authToken, forHTTPHeaderField: "x-access-token")
    
    let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error -> Void in
      
      if (error != nil) {
        callback(nil, error)
      }
      
      //      let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)!
      //      println("JSON String: \(jsonStr)")
      //
      
      if let res = response as! NSHTTPURLResponse! {
        //        if res.statusCode == 401 { // unauthorized
        //          println("Error server responded with 401: Unauthorized")
        //          NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "errorUnauthorizedNotification", object: nil))
        //        }
        if res.statusCode != 200 {
          print("Error, server responded with: \(res.statusCode)" )
          let errorMessage = self.parseError(data!)
          let e = NSError(domain: "SRP", code: 100, userInfo: [ "statusCode": res.statusCode, "message" : errorMessage ])
          callback(nil, e)
          return
        }
      }
      
      self.parseData(data!, callback: callback)
    })
    
    task.resume()
  }
  
  
  // assuming the server returns an error message in the format "message" : <the error message>
  // this method returns the message string or "undefined"
  private func parseError(data: NSData) -> String {
    
    var serializationError: NSError?
    //    var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &serializationError) as? [ String:AnyObject ]
    
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
    //    var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &serializationError) as? [ String:AnyObject ]
    
  var json: AnyObject?
    do {
      json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
    } catch let error as NSError {
      serializationError = error
      json = nil
    }
    
    //    if let response: AnyObject = json {
    //      if response.isKindOfClass(NSArray) {
    //        println("***** JSON ARRAY *****")
    //      } else {
    //        println("***** JSON DICTIONARY *****")
    //      }
    //    }
    
    if(serializationError != nil) {
      callback(nil, serializationError)
    }
    else {
      if let parsedJSON: AnyObject = json {
        //        println("RESPONSE: \(parsedJSON)")
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
