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
  
  //MARK: Following List
  func getFollowing(forUser_Id forUser_Id: String, callback: (Array<User>?) ->()) {
    API.get(nil, url: urlEncoded("follow/\(forUser_Id)")) { (res, err) -> () in
      if let e = err {
        print("Error fetching following: \(e)")
        callback(nil)
      } else {
        if let json = res as? jsonObject, followJson = json["following"] as? Array<jsonObject> {
          var following: Array<User> = []
          for follow in followJson {
            let newUser = User.userFromProfile(follow)
//            if let pastRelationshipsJson = json["pastRelationships"] as? Array<jsonObject> {
//              newUser.parsePastRelationships(pastRelationshipsJson)
//            }
            following.append(newUser)
          }
          callback(following)
        }
      }
    }
  }
  
  //MARK: Search
  func searchUsers(searchTerm: String, callback: (Array<jsonObject>?) -> ()) {
    self.userSearchResults?.removeAll()
    self.userSearchResults = Array()
    API.get(nil, url: urlEncoded("users/search/\(searchTerm)")) { (res, err) -> () in
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
  
  func createFollow(id: String, callback: (Bool) -> ()) {
    let params = [
      "following_Id" : id
    ]
    
    API.post(params, authType: .Token, url: "follow/new"){ (res, err) in
      if let e = err {
        print("Error creating follow request \(e)")
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
  
  func newLike(like: Like, callback: (Bool) -> ()) {
    let params = like.params()
    API.post(params, authType: .Token, url: "media/like/new") { (res, err) -> () in
      if let e = err {
        print("Error creating comment: \(e)")
        callback(false)
      } else {
        print("Success")
        callback(true)
      }
    }
  }
  
  func newComment(comment: Comment, callback: (Bool) -> ()) {
    let params = comment.params()
    API.post(params, authType: .Token, url: "media/comment/new") { (res, err) -> () in
      if let e = err {
        print("Error creating comment: \(e)")
        callback(false)
      } else {
        print("Success")
        callback(true)
      }
    }
  }
  
}