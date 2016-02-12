//
//  Membership.swift
//  Peat
//
//  Created by Matthew Barth on 2/11/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
class Membership: NSObject {
  
  var recipient_Id: String?
  var sender_Id: String?
  var timestamp: Double?
  var confirmed: Bool?
  
  var endedBy_Id: String?
  
  var nonCurrentUser: User?
  
  static func friendFromUnconfirmed(json: jsonObject) -> Friendship {
    let friend = Friendship()
    
    friend.confirmed = json["confirmed"] as? Bool
    friend.timestamp = json["timestamp"] as? Double
    friend.sender_Id = json["sender_Id"] as? String
    friend.recipient_Id = json["recipient-Id"] as? String
    
    friend.endedBy_Id = json["endedBy_Id"] as? String
    
    return friend
  }
  
}