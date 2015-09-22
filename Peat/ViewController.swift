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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    APIService.sharedService.post(["params":["auth_type":"Basic","user":["email":"mbmattbarth@gmail.com","password":"tittyfarts"]]], url: "") { (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          print(json)
        }
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func saveApiTokenInKeychain(tokenDict:NSDictionary) {
    // Store API AuthToken and AuthToken expiry date in KeyChain
    tokenDict.enumerateKeysAndObjectsUsingBlock({ (dictKey, dictObj, stopBool) -> Void in
      let myKey = dictKey as! String
      let myObj = dictObj as! String

      if myKey == "api_authtoken" {
        KeychainAccess.setPassword(myObj, account: "Auth_Credentials", service: "KeyChainService")
      }

      if myKey == "authtoken_expiry" {
        KeychainAccess.setPassword(myObj, account: "Auth_Token_Expiry", service: "KeyChainService")
      }
      
      if myKey == "user_email" {
        KeychainAccess.setPassword(myObj, account: "User", service: "KeyChainService")
      }
    })

    print("DID IT")
  }
  
  @IBAction func sendToken(sender: AnyObject) {
    print("something")
    if let userToken = KeychainAccess.passwordForAccount("Auth_Token", service: "KeyChainService"), tokenExpiry = KeychainAccess.passwordForAccount("Auth_Token_Expiry", service: "KeyChainService") {
      APIService.sharedService.post(["params":["auth_type":"Token", "token": ["auth_token" : "\(userToken)", "expiry" : "\(tokenExpiry)"]]], url: "") { (res, err) -> () in
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
}

