//
//  User.swift
//  Peat
//
//  Created by Matthew Barth on 10/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class User: NSObject {
  
  var name: String?
  var email: String?
  var friendsIds: Array<String>?
  var friends: Array<User>?
  
  func initWithJson(json: jsonObject) {
    if let name = json["name"] as? String, email = json["email"] as? String, friends = json["friends"] as? Array<String> {
      self.name = name
      self.email = email
      self.friendsIds = friends
    }
  }
  
  func initializeFriendsList() {
    
  }
  
}