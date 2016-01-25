//
//  User.swift
//  Peat
//
//  Created by Matthew Barth on 10/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class User: NSObject {
  
  //Info
  var _id: String?
  var first: String?
  var last: String?
  var email: String?
  var username: String?
  
  //Profile vars
  var avatarURLString: String?
  var summary: String?
  var contact: String?
  
  //Other
  var friendIds: Array<String>?
  var followingIds: Array<String>?
  
  static func userFromProfile(json: jsonObject) -> User {
    let user = User()
    
    //Info
    if let data = json["userData"] as? jsonObject {
      if let info = data["userInfo"] as? jsonObject {
        user._id = info["_id"] as? String
        user.first = info["first"] as? String
        user.last = info["last"] as? String
        user.email = info["email"] as? String
        user.username = info["username"] as? String
      }
      
      //Profile
      if let profile = data["profile"] as? jsonObject {
        user.avatarURLString = profile["avatarUrl"] as? String
        user.summary = profile["summary"] as? String
        user.contact = profile["contact"] as? String
      }
      
      //Other
      user.friendIds = data["friendIds"] as? Array<String>
      user.followingIds = data["followingIds"] as? Array<String>
    }
    return user
  }
  
//  func initWithJson(json: jsonObject) {
//    if let name = json["name"] as? String, user = json["username"] as? String, email = json["email"] as? String, friends = json["friends"] as? Array<String>, id = json["_id"] as? String {
//      self.name = name
//      self.username = user
//      self.email = email
//      self.friendsIds = friends
//      self.id = id
//    }
//  }
  
  func initializeFriendsList() {
    
  }
  
}