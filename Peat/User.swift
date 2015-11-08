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
  var username: String?
  var email: String?
  var friendsIds: Array<String>?
  var friends: Array<User>?
  var id: String?
  
  var isFriend: Bool = false
  
  func initWithJson(json: jsonObject) {
    if let name = json["name"] as? String, user = json["username"] as? String, email = json["email"] as? String, friends = json["friends"] as? Array<String>, id = json["_id"] as? String {
      self.name = name
      self.username = user
      self.email = email
      self.friendsIds = friends
      self.id = id
    }
  }
  
  func initializeFriendsList() {
    
  }
  
}