//
//  Comment.swift
//  Peat
//
//  Created by Matthew Barth on 12/27/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation


class Comment: NSObject {
  
  var sender_Id: String?
  var mediaId: String?
  var text: String?
  var timestamp: Double?
  
  static func initFromJson(json: jsonObject) -> Comment {
    let newComment = Comment()
    newComment.sender_Id = json["sender"] as? String
    newComment.mediaId = json["mediaId"] as? String
    newComment.text = json["text"] as? String
    newComment.timestamp = json["timestamp"] as? Double
    return newComment
  }

}

class Like: NSObject {
  var user_Id: String?
  var mediaId: String?
  var comment_Id: String?
  
  static func initFromJson(json: jsonObject) -> Like {
    let newLike = Like()
    newLike.user_Id = json["user_Id"] as? String
    newLike.mediaId = json["mediaId"] as? String
    newLike.comment_Id = json["comment_Id"] as? String
    return newLike
  }
  
}