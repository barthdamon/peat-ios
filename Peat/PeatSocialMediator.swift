//
//  PeatSocialMediator.swift
//  Peat
//
//  Created by Matthew Barth on 10/19/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit


private let _sharedMediator = PeatSocialMediator()

class PeatSocialMediator: NSObject {
  
  class var sharedMediator: PeatSocialMediator {
    return _sharedMediator
  }
  
  var API = APIService.sharedService
  var users: Array<User> = []
  var friends: Array<User> = []
  
  //MARK: Social/User Data
  func initializeFriendsList() {
    API.get(nil, url: "friends") { (res, err) -> () in
      if let e = err {
        print("Error fetching friends: \(e)")
        NSNotificationCenter.defaultCenter().postNotificationName("errorLoadingFriends", object: self, userInfo: nil)
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          self.saveFriendData(json)
        }
      }
    }
  }
  
  func getUsers(callback: APICallback) {
    API.get(nil, url: "users") { (res, err) -> () in
      if let e = err {
        print("Error fetching users: \(e)")
        callback(nil, err)
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          callback(json, nil)
        }
      }
    }
  }
  
  func saveFriendData(json: Dictionary<String, AnyObject>) {
    if let friends = json["friends"] as? Array<jsonObject> {
      friends.forEach({ (friend: jsonObject) -> () in
        let newFriend = User()
        newFriend.initWithJson(friend)
        self.friends.append(newFriend)
      })
      NSNotificationCenter.defaultCenter().postNotificationName("loadingFriendsComplete", object: self, userInfo: nil)
    }
  }
  
  func putFriendRelation(friendID: String) {
    API.put(["friend" : friendID], url: "friends") { (res, err) -> () in
      if let e = err {
        print("Error adding friend: \(e)")
      } else {
        print("RESPONSE \(res)")
      }
    }
  }
  
  
  
}