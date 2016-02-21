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
  var activeActivityNames: Array<String>? {
    if let activities = activeActivities {
      return activities.map({paramFor($0.name)})
    }
    return nil
  }
  
  //Other
  var avatarImage: UIImage?
  var friends: Array<User>?
  var following: Array<User>?
  var unconfirmedWitnesses: NSObject?
  var type: UserType = .Single
  
  var API = APIService.sharedService
  
  
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
      
        //Profile
        if let profile = info["profile"] as? jsonObject {
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
  
  func addFollowing(followingJson: Array<jsonObject>) {
    self.following = []
    for follow in followingJson {
      let newUser = User.userFromProfile(follow)
      self.following!.append(newUser)
    }

  }
  
  func initializeFollowingList(callback: (Bool) -> ()) {
    if let _id = self._id {
      PeatSocialMediator.sharedMediator.getFollowing(forUser_Id: _id, callback: { (following) -> () in
        if let following = following {
          self.following = following
          callback(true)
        } else {
          callback(false)
        }
      })
    }
  }
  
  func newActiveActivity(activity: Activity) {
    if let activities = self.activeActivities {
      var found = false
      for activeActivity in activities {
        if activity.name == activeActivity.name {
          found = true
        }
      }
      if !found {
        activeActivities!.append(activity)
      }
    } else {
      self.activeActivities = [activity]
    }
    updateProfile()
  }
  
  
  
  
  //MARK: Profile Updates
  
  func userParams() -> jsonObject {
    return [
      "userInfo" : [
        "first" : paramFor(first),
        "last" : paramFor(last),
        "username" : paramFor(username),
        "email" : paramFor(email),
        "type" : self.type.rawValue
      ]
    ]
  }
  
  func profileParams() -> jsonObject {
    return [
      "profile" : [
        "summary" : paramFor(summary),
        "avatarURL" : paramFor(avatarURLString),
        "contact" : paramFor(contact),
        "activeActivityNames" : activeActivityNames != nil ? activeActivityNames! : []
      ]
    ]
  }
  
  func updateProfile() {
    let params = self.profileParams()
    print("Profile Update params: \(params)")
    API.put(params, authType: .Token, url: "profile/update") { (res, err) -> () in
      if let e = err {
        print("error updating user profile: \(e)")
      } else {
        print("user profile update successful")
      }
    }
  }
  
  func updateUser() {
    let params = self.userParams()
    API.put(params, authType: .Token, url: "user/update") { (res, err) -> () in
      if let e = err {
        print("error updating user: \(e)")
      } else {
        print("user update successful")
      }
    }
  }
  
}


//MARK: Organization Specific

