//
//  ViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/10/15.
//  Copyright (c) 2015 Matthew Barth. All rights reserved.
//

import UIKit
import KeychainSwift

class ViewController: UIViewController {
  var authToken :Dictionary<String, AnyObject>?
  
  let keychain = KeychainSwift()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.
//    APIService.sharedService.post(["params":["auth_type":"Basic","user":["email":"mbmattbarth@gmail.com","password":"tittyfarts"]]], authType: HTTPRequestAuthType.Basic, url: "login") { (res, err) -> () in
//      if let e = err {
//        print("Error:\(e)")
//      } else {
//        if let json = res as? Dictionary<String, AnyObject> {
//          print(json)
//          self.saveTokenToKeychain(json)
//        }
//      }
//    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func saveTokenToKeychain(json :Dictionary<String,AnyObject>) {
    
    if let tokenExpiry = json["authtoken_expiry"] as? String {
      self.keychain.set(tokenExpiry, forKey: "authToken_expiry")
    }
    
    if let token = json["api_authtoken"] as? String {
      self.keychain.set(token, forKey: "api_authToken")
    }
    
  }
  
  @IBAction func sendToken(sender: AnyObject) {
    print("something")
      APIService.sharedService.get(nil, url: "") { (res, err) -> () in
        if let e = err {
          print("Error:\(e)")
        } else {
          if let json = res as? Dictionary<String, AnyObject> {
            print(json)
          }
        }
      }
  }
}

