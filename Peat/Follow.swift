//
//  Follow.swift
//  Peat
//
//  Created by Matthew Barth on 2/21/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

class Follow: NSObject {
  
  var follower_Id: String?
  var following_Id: String?
  var followingActivities: Set<Activity> = Set()
  var confirmed: Bool?
  
  var endedBy_Id: String?
  
  var nonCurrentUser: User?
  
//  static func friendFromUnconfirmed(json: jsonObject) -> Friendship {
//    let friend = Friendship()
//    
////    friend.follower_Id = json["follower_Id"] as? Bool
////    friend.timestamp = json["timestamp"] as? Double
////    friend.sender_Id = json["sender_Id"] as? String
////    friend.recipient_Id = json["recipient-Id"] as? String
//    
////    friend.endedBy_Id = json["endedBy_Id"] as? String
//    
//    return friend
//  }
  
}