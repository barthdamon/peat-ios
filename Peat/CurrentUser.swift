//
//  CurrentUser.swift
//  Peat
//
//  Created by Matthew Barth on 1/24/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import KeychainSwift

private let _info = CurrentUser()

//struct Mailbox {
//  var notifications: <Array>
//}

class CurrentUser: NSObject {
  
  class var info: CurrentUser {
    return _info
  }
  
  var API = APIService.sharedService
  
  var model: User?
  var friends: Array<User>?
  //store to keychain and when called return from the keychain
  var authToken: String?
  let keychain = KeychainSwift()
  
  func token() -> String? {
    if let token = authToken {
      return token
    } else if let token = keychain.get("api_authtoken") {
      self.authToken = token
      NSNotificationCenter.defaultCenter().postNotificationName("userHasToken", object: nil, userInfo: nil)
      return token
    } else {
      NSNotificationCenter.defaultCenter().postNotificationName("noUserTokenFound", object: nil, userInfo: nil)
      return nil
    }
  }
  
  func storeToken(json: jsonObject, callback: (Bool) -> ()) {
    if let token = json["api_authtoken"] as? String {
      let stored = self.keychain.set(token, forKey: "api_authtoken")
      if stored {
        self.authToken = token
        NSNotificationCenter.defaultCenter().postNotificationName("userHasToken", object: nil, userInfo: nil)
        callback(true)
      } else {
        callback(false)
      }
    } else {
      callback(false)
    }
  }
  
  func newUser(params: jsonObject, callback: (Bool) -> ()) {
    API.post(params, authType: .Basic, url: "new"){ (res, err) in
      if let e = err {
        print("Error creating user: \(e)")
        callback(false)
      } else {
        if let json = res as? jsonObject {
          self.storeToken(json, callback: callback)
        } else {
          callback(false)
        }
      }
    }
  }
  
  func logIn(params:jsonObject, callback: (Bool) -> ()) {
    API.post(params, authType: .Basic, url: "login"){ (res, err) in
      if let e = err {
        print("Error logging in user: \(e)")
        callback(false)
      } else {
        if let json = res as? jsonObject {
          self.storeToken(json, callback: callback)
        } else {
          callback(false)
        }
      }
    }
  }
  
  func logOut() {
    keychain.delete("api_authtoken")
    NSNotificationCenter.defaultCenter().postNotificationName("userLoggedOut", object: nil, userInfo: nil)
  }
  
  
  func fetchProfile(callback: (Bool) -> ()) {
    API.get(nil, url: "currentUser/profile") { (res, err) in
      if let e = err {
        print("Error fetching user profile: \(e)")
        callback(false)
      } else {
        if let json = res as? jsonObject, userData = json["userData"] as? jsonObject {
          print("PROFILE RESPONSE: \(json)")
          self.model = User.userFromProfile(userData)
          callback(true)
        } else {
          callback(false)
        }
      }
    }
  }
  
  func isFriend(user: User) -> Bool {
    if let friends = self.model?.friends {
      for friend in friends {
        if user._id == friend._id {
          return true
        }
      }
      return false
    } else {
      return false
    }
  }
  
  func getMailbox() {
    API.get(nil, url: "mail/requests"){ (res, err) in
      if let e = err {
        print("Error fetching mailbox: \(e)")
    
      } else {
        if let json = res as? jsonObject {
          
        }
      }
    }
  }
  
}