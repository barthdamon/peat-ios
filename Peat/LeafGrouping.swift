//
//  LeafGrouping.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


class LeafGrouping: NSObject {
  
  var zIndex: Int?
  var name: String?
  var colorString: String?
  
  var rgbColor: UIColor? {
    didSet {
      self.colorString = rgbColor?.hexString()
    }
  }
  
  
  static func newGrouping(name: String) -> LeafGrouping {
    let newGrouping = LeafGrouping()
    newGrouping.rgbColor = UIColor.redColor()
    newGrouping.name = name
    
    return newGrouping
  }
  
  static func groupingFromJson(json: jsonObject) -> LeafGrouping {
    let grouping = LeafGrouping()
    grouping.name = json["name"] as? String
    grouping.zIndex = json["zIndex"] as? Int
    grouping.colorString = json["colorString"] as? String
    if let colorString = grouping.colorString {
      grouping.rgbColor = UIColor.fromHex(colorString)
    }
    return grouping
  }
  
  func params() -> Dictionary<String, String> {
    return [
      "zIndex": self.zIndex != nil ? "\(self.zIndex!)" : "",
      "name": self.name != nil ? self.name! : "",
      "colorString": self.colorString != nil ? self.colorString! : ""
    ]
  }
  
  //need a color slider and everything
  func updateGroupingColor(color: UIColor) {
    
  }
  
  
  
}