//
//  Comment.swift
//  Peat
//
//  Created by Matthew Barth on 12/27/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation


class Comment: NSObject {
  
  var _id: String?
  var sender_Id: String?
  var mediaId: String?
  var text: String?
  var timestamp: Double?
  
  var user: User?
  
  static func initFromJson(json: jsonObject) -> Comment {
    let newComment = Comment()
    newComment._id = json["_id"] as? String
    newComment.sender_Id = json["sender"] as? String
    newComment.mediaId = json["mediaId"] as? String
    newComment.text = json["text"] as? String
    newComment.timestamp = json["timestamp"] as? Double
    if let userInfo = json["userInfo"] as? jsonObject {
      newComment.user = User.userFromProfile(userInfo)
    }
    return newComment
  }
  
  static func newComment(text: String, mediaId: String, user: User) -> Comment {
    let newComment = Comment()
    newComment.user = user
    newComment.text = text
    newComment.mediaId = mediaId
    newComment.sender_Id = user._id
    return newComment
  }
  
  func params() -> jsonObject {
    return [
      "sender_Id" : paramFor(sender_Id),
      "mediaId" : paramFor(mediaId),
      "text" : paramFor(text)
    ]
  }

}

class Like: NSObject {
  var user_Id: String?
  var mediaId: String?
  var comment_Id: String?
  
  var user: User?
  
  static func initFromJson(json: jsonObject) -> Like {
    let newLike = Like()
    newLike.user_Id = json["user_Id"] as? String
    newLike.mediaId = json["mediaId"] as? String
    newLike.comment_Id = json["comment_Id"] as? String
    if let userInfo = json["userInfo"] as? jsonObject {
      newLike.user = User.userFromProfile(userInfo)
    }
    return newLike
  }
  
  static func newLike(user: User, mediaId: String?, comment_Id: String?) -> Like {
    let newLike = Like()
    newLike.user = user
    newLike.user_Id = user._id
    newLike.mediaId = mediaId
    newLike.comment_Id = comment_Id
    return newLike
  }
  
  func params() -> jsonObject {
    return [
      "user_Id" : paramFor(user_Id),
      "mediaId" : paramFor(mediaId),
      "comment_Id" : paramFor(comment_Id)
    ]
  }
}