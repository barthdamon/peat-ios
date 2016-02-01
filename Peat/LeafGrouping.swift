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
  
  var groupingView: UIView?
  var groupingId: String?
  
  var center: CGPoint?
  var height: Int?
  var width: Int?
  
  var leafIds: Array<String>?
  
  var rgbColor: UIColor? {
    didSet {
      self.colorString = rgbColor?.hexString()
    }
  }
  
  
  static func newGrouping(center: CGPoint) -> LeafGrouping {
    let newGrouping = LeafGrouping()
    newGrouping.center = center
    //generate random color
    newGrouping.rgbColor = UIColor.redColor()
    newGrouping.groupingId = generateId()
    
    return newGrouping
  }
  
  static func groupingFromJson(json: jsonObject) -> LeafGrouping {
    let grouping = LeafGrouping()
    grouping.name = json["name"] as? String
    grouping.zIndex = json["zIndex"] as? Int
    grouping.colorString = json["colorString"] as? String
    if let layout = json["layout"] as? jsonObject {
      if let coordinates = layout["center"] as? jsonObject, x = coordinates["x"] as? Int, y = coordinates["y"] as? Int {
        grouping.center = CGPoint(x: x, y: y)
      }
    }
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