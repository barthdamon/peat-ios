//
//  Activity.swift
//  Peat
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

class Activity: NSObject {
  var name: String?
  var _id: String?
  var category: String?
  var approved: Bool?
  
  static func activityFromJson(json: jsonObject) -> Activity {
    let newActivity = Activity()
    newActivity.name = json["name"] as? String
    newActivity._id = json["_id"] as? String
    newActivity.category = json["category"] as? String
    newActivity.approved = json["approved"] as? Bool
    return newActivity
  }
  
  static func activityFromName(name: String) -> Activity {
    let newActivity = Activity()
    newActivity.name = name
    return newActivity
  }
}