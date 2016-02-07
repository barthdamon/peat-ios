//
//  Witness.swift
//  Peat
//
//  Created by Matthew Barth on 2/6/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

class Witness: NSObject {
  var _id: String?
  var leafId: String?
  var timestamp: String?
  var witness_Id: String?
  var witnessed_Id: String?
  
  static func initFromJson(json: jsonObject) -> Witness {
    let newWitness = Witness()
    newWitness._id = json["_id"] as? String
    newWitness.leafId = json["leafId"] as? String
    newWitness.witness_Id = json["witness_Id"] as? String
    newWitness.witnessed_Id = json["witnessed_Id"] as? String
    return newWitness
  }
}