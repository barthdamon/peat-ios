//
//  Leaf.swift
//  Peat
//
//  Created by Matthew Barth on 10/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

protocol TreeDelegate {
  func drawConnectionLayer(connection: CAShapeLayer)
  func fetchTreeData()
  func addLeafToScrollView(leaf: Leaf)
  func drillIntoLeaf(leaf: Leaf)
  func leafBeingMoved(leaf: Leaf, sender: UIGestureRecognizer)
  func checkForOverlaps(intruder: Leaf)
}

typealias CoordinatePair = (x: CGFloat, y: CGFloat)
typealias LeafConnection = (leafId: String, type: LeafConnectionType)

class Leaf: NSObject {
  
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
  var previousCenter: CGPoint?
  var center: CGPoint?
  var connections: Array<LeafConnection>?
  var groupings: Array<String>?
  
  // Leaf Contents
  var mediaIds: Array<String>?
  var comment_Ids: Array<String>?
  var like_Ids: Array<String>?
  
  // Leaf
  var treeDelegate: TreeDelegate?
  var view: UIView?
  var _id: String?
  var leafId: String?
  var activityName: String?
  var completionStatus: CompletionStatus?
  var title: String?
  var timestamp: Int?
  var details: String?
  
  var movingEnabled: Bool = false
  
  
// MARK: INITIALIZATION
  
  static func initWithJson(json: jsonObject, delegate: TreeDelegate?) -> Leaf {
    let leaf = Leaf()
    leaf.treeDelegate = delegate
    leaf._id = json["_id"] as? String
    leaf.leafId = json["leafId"] as? String
    leaf.activityName = json["activityName"] as? String
    if let status = json["completionStatus"] as? String {
      leaf.completionStatus = CompletionStatus(rawValue: status)
    }
    leaf.timestamp = json["timestamp"] as? Int
    leaf.details = json["description"] as? String
    leaf.title = json["title"] as? String
    
    if let layout = json["layout"] as? jsonObject {
      leaf.groupings = layout["groupings"] as? Array<String>
      if let connections = layout["connections"] as? Array<jsonObject> {
        leaf.connections = Array()
        for connection in connections {
          if let leafId = connection["leafId"] as? String, typeString = connection["type"] as? String, type = LeafConnectionType(rawValue: typeString) {
            leaf.connections!.append((leafId: leafId, type: type))
          }
        }
      }
      if let coordinates = layout["coordinates"] as? jsonObject, x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        leaf.center = CGPoint(x: x, y: y)
      }
    }
    return leaf
  }
  
  static func initFromTree(center: CGPoint, delegate: TreeDelegate) -> Leaf {
    let newLeaf = Leaf()
    newLeaf.center = center
    newLeaf.treeDelegate = delegate
    return newLeaf
  }
  
  func addGestureRecognizers() {
    if let view = self.view {
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: "leafDrilldownInitiated")
      tapRecognizer.numberOfTapsRequired = 1
      tapRecognizer.numberOfTouchesRequired = 1
      view.addGestureRecognizer(tapRecognizer)
      
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "leafMoveInitiated:")
      longPressRecognizer.minimumPressDuration = 1
      view.addGestureRecognizer(longPressRecognizer)
      
      let movingPanRecognizer = UIPanGestureRecognizer(target: self, action: "leafBeingMoved:")
      view.addGestureRecognizer(movingPanRecognizer)
    }
  }
  
  func setDelegate(delegate: TreeDelegate) {
    self.treeDelegate = delegate
  }
  
  func initiateLeafDrilldown() {
    
  }
  
  func leafMoveInitiated(sender: UILongPressGestureRecognizer) {
    let state = sender.state
    if state == UIGestureRecognizerState.Changed {
      leafBeingMoved(sender)
    } else if state == UIGestureRecognizerState.Ended {
//      movingEnabled = false
//      deselectLeaf()
    } else {
      self.drawLeafSelected()
      self.movingEnabled = true
    }
  }
  
  func leafBeingMoved(sender: UIGestureRecognizer) {
    if movingEnabled {
      self.treeDelegate?.leafBeingMoved(self, sender: sender)
    }
  }
  
  func deselectLeaf() {
    if let view = self.view {
      view.backgroundColor = UIColor.whiteColor()
      view.layer.shadowColor = UIColor.clearColor().CGColor
      view.layer.shadowOpacity = 0
      view.layer.shadowRadius = 0
      view.layer.shadowOffset = CGSizeMake(0, 0)
      view.layer.shadowRadius = 0
    }
  }
  
  func drawLeafSelected() {
    if let view = self.view {
//      view.layer.borderColor = UIColor.darkGrayColor().CGColor
//      view.layer.borderWidth = 2
      view.backgroundColor = UIColor.yellowColor()
      view.layer.shadowColor = UIColor.darkGrayColor().CGColor
      view.layer.shadowOpacity = 0.8
      view.layer.shadowRadius = 3.0
      view.layer.shadowOffset = CGSizeMake(7, 7)
      
    }
  }
  
  
// MARK: DRAWING
  func parseConnections() {
    //Note: need to add more data in connections
    //    for connection in connections {
    //      if let leaf = PeatContentStore.sharedStore.findLeafWithId(connection) {
    //        self.connectedLeaves.append(leaf)
    //      }
    //    }
  }
  
  func generateBounds() {
    if let center = center {
      referenceFrame = (x: center.x - Leaf.xOffset, y: center.y - Leaf.yOffset)
      createFrame()
    }
  }
  
  func createFrame() {
    if let frame = referenceFrame {
      let frame = CGRectMake(frame.x, frame.y, Leaf.standardWidth, Leaf.standardHeight)
      view = UIView(frame: frame)
      if let view = self.view {
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = 10
//        view.backgroundColor = self.completionStatus ? UIColor.yellowColor() : UIColor.darkGrayColor()
        addGestureRecognizers()
        
        treeDelegate?.addLeafToScrollView(self)
      }
    }
  }
  
  func drawConnections() {
//    parseConnections()
//    for connection in self.connectedLeaves {
//      if let center = center, connectedCenter = connection.center {
//      
//      let path = UIBezierPath()
//      path.moveToPoint(center)
//      path.addLineToPoint(connectedCenter)
//      
//      let shapeLayer = CAShapeLayer()
//      shapeLayer.path = path.CGPath
//      if self.completionStatus {
//        shapeLayer.strokeColor = connection.completionStatus ? UIColor.greenColor().CGColor : UIColor.grayColor().CGColor
//      } else {
//        shapeLayer.strokeColor = UIColor.grayColor().CGColor
//      }
//      shapeLayer.lineWidth = 3.0
//      shapeLayer.fillColor = UIColor.blackColor().CGColor
//      //LOL @SETH
//      shapeLayer.zPosition = -1
//      treeDelegate?.drawConnectionLayer(shapeLayer)
//      }
//    }
  }
  
  func leafDrilldownInitiated() {
    if movingEnabled {
      movingEnabled = false
      deselectLeaf()
      treeDelegate?.checkForOverlaps(self)
    } else {
      treeDelegate?.drillIntoLeaf(self)
    }
  }
  
}
