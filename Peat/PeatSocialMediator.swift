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
  
  var userSearchResults: Array<User>?
  
  //MARK: Friends List
  func getFriends(forUser_Id forUser_Id: String, callback: (Array<User>?) ->()) {
    API.get(nil, url: "friends/\(forUser_Id)") { (res, err) -> () in
      if let e = err {
        print("Error fetching friends: \(e)")
        callback(nil)
      } else {
        if let json = res as? jsonObject, friendJson = json["friends"] as? Array<jsonObject> {
          var friends: Array<User> = []
          for friend in friendJson {
            let newUser = User.userFromProfile(friend)
            if let pastRelationshipsJson = json["pastRelationships"] as? Array<jsonObject> {
              newUser.parsePastRelationships(pastRelationshipsJson)
            }
            friends.append(newUser)
          }
          callback(friends)
        }
      }
    }
  }
  
  //MARK: Search
  func searchUsers(searchTerm: String, callback: (Array<jsonObject>?) -> ()) {
    self.userSearchResults?.removeAll()
    self.userSearchResults = Array()
    API.get(nil, url: "users/search/\(searchTerm)") { (res, err) -> () in
      if let e = err {
        print("Error fetching users: \(e)")
        callback(nil)
      } else {
        if let json = res as? jsonObject, users = json["users"] as? Array<jsonObject> {
          callback(users)
        }
      }
    }
  }
  
  func createFriendRequest(id: String, callback: (Bool) -> ()) {
    API.post(nil, authType: .Token, url: "friends/\(id)"){ (res, err) in
      if let e = err {
        print("Error creating friend request \(e)")
        callback(false)
      } else {
        callback(true)
      }
    }
  }
  
  func confirmFriendRequest(id: String, callback: (Bool) -> ()) {
    API.put(nil, url: "friends/\(id)") { (res, err) -> () in
      if let e = err {
        print("Error confirming friend request \(e)")
        callback(false)
      } else {
        callback(true)
      }
    }
  }
  
  func destroyFriendRequest(id: String, callback: (Bool) -> ()) {
    API.put(nil, url: "friends/remove/\(id)") { (res, err) -> () in
      if let e = err {
        print("Error removing friend request \(e)")
        callback(false)
      } else {
        callback(true)
      }
    }
  }
  
  func sendWitnessRequest(params: jsonObject, callback: (Bool) -> () ) {
    API.post(params, authType: .Token, url: "witness/new") { (res, err) -> () in
      if let e = err {
        print("Error creating witness request: \(e)")
        callback(false)
      } else {
        print("Witness create success")
        callback(true)
      }
    }
  }
  
}