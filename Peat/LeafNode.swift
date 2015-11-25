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
  func drillIntoLeaf(leaf: LeafNode)
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
  var connections: Array<String> = []
  var connectedLeaves: Array<LeafNode> = []
  
  // Media Specific
  var activity: Activity?
  var completionStatus: Bool = false
  var abilityTitle: String?
  
  // Other
  var treeDelegate: TreeDelegate?
  var view: UIView?
  var id: String?
  
  
// MARK: INITIALIZATION
  
  func initWithJson(json: jsonObject, delegate: TreeDelegate?) {
    if let id = json["_id"] as? String, activity = json["activity"] as? String, coordinates = json["coordinates"] as? jsonObject, title = json["abilityTitle"] as? String, status = json["completionStatus"] as? Bool {
      self.id = id
      if let delegate = delegate {
        self.treeDelegate = delegate
      }
      self.activity = parseActivity(activity)
      self.completionStatus = status
      self.abilityTitle = title
      if let x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        self.centerCoords = (x: x, y: y)
        self.center = CGPoint(x: x, y: y)
      }
      
      if let connections = json["connections"] as? Array<String> {
        self.connections = connections
      }
    }
    
    //locally set variables:
//    self.abilityTitle = "360, Bitch"
  }
  
  func setDelegate(delegate: TreeDelegate) {
    self.treeDelegate = delegate
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
        view.backgroundColor = self.completionStatus ? UIColor.yellowColor() : UIColor.darkGrayColor()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "leafDrilldownInitiated")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapRecognizer)
        
        treeDelegate?.addLeafToScrollView(view)
      }
    }
  }
  
  func parseConnections() {
    //Note: need to add more data in connections
    for connection in connections {
      if let leaf = PeatContentStore.sharedStore.findLeafWithId(connection) {
        self.connectedLeaves.append(leaf)
      }
    }
  }
  
  func drawConnections() {
    parseConnections()
    for connection in self.connectedLeaves {
      if let center = center, connectedCenter = connection.center {
      
      let path = UIBezierPath()
      path.moveToPoint(center)
      path.addLineToPoint(connectedCenter)
      
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      if self.completionStatus {
        shapeLayer.strokeColor = connection.completionStatus ? UIColor.greenColor().CGColor : UIColor.grayColor().CGColor
      } else {
        shapeLayer.strokeColor = UIColor.grayColor().CGColor
      }
      shapeLayer.lineWidth = 3.0
      shapeLayer.fillColor = UIColor.blackColor().CGColor
      //LOL @SETH
      shapeLayer.zPosition = -1
      treeDelegate?.drawConnectionLayer(shapeLayer)
      }
    }
  }
  
  func leafDrilldownInitiated() {
    treeDelegate?.drillIntoLeaf(self)
  }

  
  
  
}
