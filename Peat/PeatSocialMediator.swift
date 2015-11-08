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
  var userSearchResults: Array<User> = []
  
  //MARK: Friends List
  func initializeFriendsList() {
    API.get(nil, url: "friends") { (res, err) -> () in
      if let e = err {
        print("Error fetching friends: \(e)")
        NSNotificationCenter.defaultCenter().postNotificationName("errorLoadingFriends", object: self, userInfo: nil)
      } else {
        if let json = res as? jsonObject {
          self.saveFriendData(json)
        }
      }
    }
  }
  
  func saveFriendData(json: jsonObject) {
    if let friends = json["friends"] as? Array<jsonObject> {
      for friend in friends {
        let newFriend = User()
        newFriend.initWithJson(friend)
        newFriend.isFriend = true
        self.friends.append(newFriend)
      }
      NSNotificationCenter.defaultCenter().postNotificationName("loadingFriendsComplete", object: self, userInfo: nil)
    }
  }
  
  //MARK: Changing Friend Relation
  
  func putFriendRelation(friendID: String, callback: APICallback) {
    API.put(["friend" : friendID], url: "friends") { (res, err) -> () in
      if let e = err {
        print("Error adding friend: \(e)")
        callback(nil, e)
      } else {
        print("RESPONSE \(res)")
        callback(res, nil)
      }
    }
  }
  
  //MARK: Search
  func searchUsers(searchTerm: String) {
    self.userSearchResults.removeAll()
    API.post(["searchTerm" : searchTerm], authType: .Token, url: "users/search") { (res, err) -> () in
      if let e = err {
        print("Error fetching users: \(e)")
      } else {
        if let json = res as? jsonObject {
          self.generateSearchedUsers(json)
        }
      }
    }
  }
  
  func generateSearchedUsers(json: jsonObject) {
    if let users = json["users"] as? Array<jsonObject> {
      for user in users {
        let newUser = User()
        newUser.initWithJson(user)
        for friend in self.friends {
          if friend.id == newUser.id {
            newUser.isFriend = true
          }
        }
        self.userSearchResults.append(newUser)
      }
      NSNotificationCenter.defaultCenter().postNotificationName("recievedSearchResults", object: self, userInfo: nil)
    }
  }
  
  
  
}