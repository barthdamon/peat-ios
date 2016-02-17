//
//  User.swift
//  Peat
//
//  Created by Matthew Barth on 10/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

enum UserType: String {
  case Organization = "organization"
  case Single = "single"
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
  var activeActivities: Array<Activity>?
  
  //Other
  var avatarImage: UIImage?
  var friends: Array<User>?
  
//  var unconfirmedFriendship: Membership?
  var unconfirmedWitnesses: NSObject?
  
  var following: Array<User>?
  var type: UserType = .Single
  
  
//MARK: General
  static func userFromProfile(json: jsonObject) -> User {
    let user = User()
    
    //Info
      if let info = json["userInfo"] as? jsonObject {
        user._id = info["_id"] as? String
        user.first = info["first"] as? String
        user.last = info["last"] as? String
        user.email = info["email"] as? String
        user.username = info["username"] as? String
        if let type = info["type"] as? String, rawType = UserType(rawValue: type) {
          user.type = rawType
        }
      }
      
      //Profile
      if let profile = json["profile"] as? jsonObject {
        user.avatarURLString = profile["avatarUrl"] as? String
        user.summary = profile["summary"] as? String
        user.contact = profile["contact"] as? String
        if let activities = profile["activeActivityNames"] as? Array<String> {
          user.activeActivities = []
          for activity in activities {
            user.activeActivities!.append(Activity.activityFromName(activity))
          }
          //if you need to go get the actual activity model, but you dont need to yet so dont
        }
      }
    
    if let memberships = json["memberships"] as? Array<jsonObject> {
      //type: admin, sponsor: true - keep them the same. a membership can be a sponsorship?
      //create memberships
    }
    
//    if let sponsorships = json["sponsorships"] as? Array<jsonObject> {
//      
//    }
    
    return user
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


//MARK: Organization Specific

