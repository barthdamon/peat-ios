//
//  LeafNode.swift
//  Peat
//
//  Created by Matthew Barth on 10/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit


protocol TreeDelegate {
  func drawConnectionLayer(connection: CAShapeLayer)
  func initializeLeaves() -> Bool
  func addLeafToScrollView(leafView: UIView)
}

typealias CoordinatePair = (x: CGFloat, y: CGFloat)

class LeafNode: NSObject {
  
  // Leaf Standards
  static let standardWidth: CGFloat = 100
  static let standardHeight: CGFloat = 50
  
  // Reference Variables
  var referenceFrame: CoordinatePair?
  class var xOffset: CGFloat {
    return standardWidth / 2
  }
  class var yOffset: CGFloat {
    return standardHeight / 2
  }
  // Unique Drawing Variables
  var centerCoords: CoordinatePair?
  var center: CGPoint?
  var connections: Array<CGPoint> = []
  
  // Media Specific
  var activity: Activity?
  
  // Other
  var treeDelegate: TreeDelegate?
  var view: UIView?
  
  
// MARK: INITIALIZATION
//  init(coords: CoordinatePair, delegate: TreeDelegate) {
//    super.init()
//    self.treeDelegate = delegate
//    center = CGPoint(x: coords.x, y: coords.y)
//    generateBounds()
//  }
  
  func initWithJson(json: jsonObject, delegate: TreeDelegate) {
    if let activity = json["activity"] as? String, coordinates = json["coordinates"] as? jsonObject {
      self.treeDelegate = delegate
      self.activity = parseActivity(activity)
      if let x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        self.centerCoords = (x: x, y: y)
        self.center = CGPoint(x: x, y: y)
      }
      
      if let connections = json["connections"] as? Array<jsonObject> {
        parseConnections(connections)
      }
    }
  }
  
  func setDelegate(delegate: TreeDelegate) {
    self.treeDelegate = delegate
  }
  
  func parseConnections(connections: Array<jsonObject>) {
    //Note: need to add more data in connections
    for connection in connections {
      if let coordinates = connection["coordinates"] as? jsonObject, x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        self.connections.append(CGPoint(x: x, y: y))
      }
    }
  }
  
  
// MARK: DRAWING
  func generateBounds() {
    if let center = center {
      referenceFrame = (x: center.x - LeafNode.xOffset, y: center.y - LeafNode.yOffset)
      createFrame()
    }
  }
  
  func createFrame() {
    if let frame = referenceFrame {
      let frame = CGRectMake(frame.x, frame.y, LeafNode.standardWidth, LeafNode.standardHeight)
      view = UIView(frame: frame)
      if let view = self.view {
        view.backgroundColor = .yellowColor()
        treeDelegate?.addLeafToScrollView(view)
      }
    }
  }
  
  func drawConnections() {
    if let center = center {
      for connection in self.connections {
        let path = UIBezierPath()
        path.moveToPoint(center)
        path.addLineToPoint(connection)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.CGPath
        shapeLayer.strokeColor = UIColor.greenColor().CGColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.fillColor = UIColor.blackColor().CGColor
        //LOL @SETH
        shapeLayer.zPosition = -1
        treeDelegate?.drawConnectionLayer(shapeLayer)
      }
    }
  }

  
  
  
}
