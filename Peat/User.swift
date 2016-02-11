//
//  User.swift
//  Peat
//
//  Created by Matthew Barth on 10/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

enum UserType: String {
  case Pro = "pro"
  case Org = "org"
  case Sponsor = "sponsor"
  case Normal = "normal"
}

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
  var avatarImage: UIImage?
  var friends: Array<User>?
  var unconfirmedFriendship: Friendship?
  var unconfirmedWitness: NSObject?
  
  var following: Array<User>?
  
  static func userFromProfile(json: jsonObject) -> User {
    let user = User()
    
    //Info
      if let info = json["userInfo"] as? jsonObject {
        user._id = info["_id"] as? String
        user.first = info["first"] as? String
        user.last = info["last"] as? String
        user.email = info["email"] as? String
        user.username = info["username"] as? String
      }
      
      //Profile
      if let profile = json["profile"] as? jsonObject {
        user.avatarURLString = profile["avatarUrl"] as? String
        user.summary = profile["summary"] as? String
        user.contact = profile["contact"] as? String
      }
    
    
    //MARK: Parsing specific traits for other users (not found on current user)
    if let friendshipJson = json["unconfirmedFriendship"] as? jsonObject {
      user.unconfirmedFriendship = Friendship.friendFromUnconfirmed(friendshipJson)
    }
    
    if let witnessJson = json["unconfirmedWitnesses"] as? jsonObject {
      user.unconfirmedWitness = witnessJson
    }
    
    return user
  }
  
  func parsePastRelationships(json: Array<jsonObject>) {
    
  }
  
  func generateAvatarImage(callback: (UIImage) -> ()) {
    if let image = self.avatarImage {
      callback(image)
    } else {
      if let urlString = avatarURLString, url = NSURL(string: urlString) {
        UIImage.loadAsync(url, callback: { (image: UIImage) -> () in
          self.avatarImage = image
          callback(image)
        })
      }
    }
  }
  
  func initializeFriendsList(callback: (Bool) -> ()) {
    if let _id = self._id {
      PeatSocialMediator.sharedMediator.getFriends(forUser_Id: _id, callback: { (friends) -> () in
        if let friends = friends {
          self.friends = friends
          callback(true)
        } else {
          callback(false)
        }
      })
    }
  }
  
}

