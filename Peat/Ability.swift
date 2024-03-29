//
//  Ability.swift
//  Peat
//
//  Created by Matthew Barth on 2/15/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

@objc class Ability: NSObject {
  var name: String?
  var _id: String?
  
  static func abilityFromJson(json: jsonObject) -> Ability {
    let newAbility = Ability()
    newAbility.name = json["name"] as? String
    newAbility._id = json["_id"] as? String
    return newAbility
  }
  
  static func abilityFromLeaf(json: jsonObject) -> Ability {
    let newAbility = Ability()
    newAbility.name = json["abilityName"] as? String
    newAbility._id = json["ability_Id"] as? String
    return newAbility
  }
  //dont need params cause ability is mostly server side
}