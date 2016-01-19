//
//  Comment.swift
//  Peat
//
//  Created by Matthew Barth on 12/27/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation


class Comment: NSObject {
  
  var sender: String?
  var media: [String]?
  var witnessEvent: Bool?
  var text: String?
  var timestamp: Int?
  
  func initFromJson(json: jsonObject) {
    
    
  }
  
}