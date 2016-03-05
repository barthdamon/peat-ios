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
  var name: String?
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
  var newAvatarImage: UIImage?
  var avatarFilePath: NSURL?
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
        user.name = info["name"] as? String
        user.email = info["email"] as? String
        user.username = info["username"] as? String
        if let type = info["type"] as? String, rawType = UserType(rawValue: type) {
          user.type = rawType
        }
      
        //Profile
        if let profile = info["profile"] as? jsonObject {
          user.avatarURLString = profile["avatarURL"] as? String
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
      } else {
        if let defaultImage = UIImage(named: "friends") {
          callback(defaultImage)
        }
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
    updateUser() { (success) in
      print("user updated with new activity")
    }
  }
  
  
  
  
  //MARK: Profile Updates
  
  func userParams() -> jsonObject {
    return [
      "name" : paramFor(name),
      "username" : paramFor(username),
      "email" : paramFor(email),
      "type" : self.type.rawValue,
      "profile" : [
        "summary" : paramFor(summary),
        "avatarURL" : paramFor(avatarURLString),
        "contact" : paramFor(contact),
        "activeActivityNames" : activeActivityNames != nil ? activeActivityNames! : []
      ]
    ]
  }
  
  func updateUser(callback: (Bool) -> ()) {
    func readyForProfileUpdate() {
      let params = self.userParams()
      print("Profile Update params: \(params)")
      API.put(["user" : params], authType: .Token, url: "user/update") { (res, err) -> () in
        if let e = err {
          print("error updating user: \(e)")
          callback(false)
        } else {
          print("user update successful")
          NSNotificationCenter.defaultCenter().postNotificationName("profileUpdated", object: nil, userInfo: nil)
          callback(true)
        }
      }
    }
    
    if let _ = newAvatarImage {
      postAvatarImage({ (success) -> () in
        //remember need the url of the new image
        //set the urlString as the new avatarURL
        if success {
          readyForProfileUpdate()
        } else {
          callback(false)
        }
      })
    } else {
      readyForProfileUpdate()
    }

  }
  
  func postAvatarImage(callback: (Bool) -> ()) {
    //need the filepath damnet
    // so make an object, post it, save the url to the user. then when saving on the server first post the new media, then update the user profile with the new url, and then remove the media with the url of the old profile avatar url
    let avatarObject = MediaObject.initFromUploader(nil, type: .Image, thumbnail: newAvatarImage, filePath: nil, store: nil)
    avatarObject.publish("media") { (success) -> () in
      //make sure to set the url string
      self.avatarURLString = avatarObject.urlString
      self.avatarImage = self.newAvatarImage
      callback(success)
    }
  }
  
}


//MARK: Organization Specific

