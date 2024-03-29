//
//  LeafConnection.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
class LeafConnection: NSObject {
  
  static var standardLayerWidth: CGFloat = 10.0
  
  var connectionId: String?
  var changeStatus: ChangeStatus = .Unchanged
  var user_Id: String?
  var fromId: String?
  var toId: String?
  
  //these points need to be set relative to the objects centers I beleve so that if we move the objects centers they still work.
  //also need to work if we expand the objects
  // the offset points
  var fromObjectPoint: CGPoint?
  var toObjectPoint: CGPoint?
  
  var type: LeafConnectionType?
  var activityName: String?
  
  var fromObject: TreeObject? {
    didSet {
      fromId = fromObject?.objectId()
    }
  }
  var toObject: TreeObject? {
    didSet {
      toId = toObject?.objectId()
    }
  }
  
  var treeDelegate: TreeDelegate?
  var connectionLayer: CAShapeLayer?
  var arrow: UIImageView? {
    didSet {
      arrow!.userInteractionEnabled = true
      
      let connectionTap = UITapGestureRecognizer(target: self, action: "rotateType")
      connectionTap.numberOfTouchesRequired = 1
      connectionTap.numberOfTapsRequired = 1
      arrow!.addGestureRecognizer(connectionTap)
      
      let connectionPress = UILongPressGestureRecognizer(target: self, action: "deleteConnection")
      connectionPress.minimumPressDuration = 1
      arrow!.addGestureRecognizer(connectionPress)
    }
  }
  
  static func newConnection(layer: CAShapeLayer, arrow: UIImageView?, from: TreeObject?, to: TreeObject?, delegate: TreeDelegate) -> LeafConnection {
    let newConnection = LeafConnection()
    newConnection.user_Id = CurrentUser.info.model?._id
    newConnection.arrow = arrow
    newConnection.type = .Pre
    newConnection.changeStatus = .BrandNew
    newConnection.fromObject = from
    newConnection.toObject = to
    newConnection.connectionLayer = layer
    if let activity = delegate.getCurrentActivity(), name = activity.name {
      newConnection.activityName = name
    }

    return newConnection
  }
  
  static func initFromJson(json: jsonObject, delegate: TreeDelegate?) -> LeafConnection {
    let newConnection = LeafConnection()
    newConnection.connectionId = json["connectionId"] as? String
    newConnection.treeDelegate = delegate
    newConnection.activityName = json["activityName"] as? String
    newConnection.toId = json["toId"] as? String
    newConnection.fromId = json["fromId"] as? String
    if let type = json["type"] as? String {
      newConnection.type = LeafConnectionType(rawValue: type)
    }
    newConnection.user_Id = json["user_Id"] as? String
    return newConnection
  }
  
  func changed(status: ChangeStatus) {
    //Note: might break on server when updating a leaf that got removed before being created on server
    guard changeStatus == .BrandNew && status == .Updated else { changeStatus = status; return}
  }
  
  func params() -> Dictionary<String, AnyObject> {
    return [
      "connectionId": paramFor(connectionId),
      "user_Id": paramFor(user_Id),
      "type": self.type != nil ? self.type!.rawValue : "",
      "activityName" : paramFor(activityName),
      "toId": paramFor(toId),
      "fromId": paramFor(fromId),
      "toObjectPoint": [
        "x": toObjectPoint?.x != nil ? toObjectPoint!.x : 0,
        "y" : toObjectPoint?.y != nil ? toObjectPoint!.y : 0
      ],
      "fromObjectPoint": [
        "x": fromObjectPoint?.x != nil ? fromObjectPoint!.x : 0,
        "y": fromObjectPoint?.y != nil ? fromObjectPoint!.y : 0
      ]
    ]
  }
  
  func rotateType() {
    if let type = self.type {
      switch type {
      case .Pre:
        self.type = .Post
        self.rotateArrow()
      case .Post:
        self.type = .Even
        self.arrow?.image = nil
      case .Even:
        self.type = .Pre
        self.rotateArrow()
        self.arrow?.image = UIImage(named: "up-arrow")
      }
      changed(.Updated)
      NSNotificationCenter.defaultCenter().postNotificationName("connectionChangesMade", object: nil, userInfo: nil)
    }
  }
  
  func deleteConnection() {
    self.connectionLayer?.removeFromSuperlayer()
    self.arrow?.removeFromSuperview()
    self.treeDelegate?.sharedStore().removeConnection(self)
    changed(.Removed)
  }
  
  func rotateArrow() {
    //code to rotate the arrow
//    let opposite: Int = 180
//    let rotation = CGAffineTransformMakeRotation(opposite.degreesToRadians)
    if let arrow = arrow {
      let currentRotation = CGFloat(atan2f(Float(arrow.transform.b), Float(arrow.transform.a)))
      let rTransform = 180.degreesToRadians
      let rotation = CGAffineTransformMakeRotation(currentRotation + rTransform)
      arrow.transform = rotation
      setCompletionColor()
    }
    self.treeDelegate?.changesMade()
    //tell changes made

  }
  
  func setCompletionColor() {
    var color = UIColor.grayColor().CGColor
    let completedColor = UIColor.greenColor().CGColor
    var toCompleted = false
    var fromCompleted = false
    if let toObject = self.toObject {
      if toObject.isCompleted() {
        toCompleted = true
      }
    }
    if let fromObject = self.fromObject {
      if fromObject.isCompleted() {
        fromCompleted = true
      }
    }
    
    if let type = self.type {
      switch type {
      case .Pre:
        if toCompleted {
          color = completedColor
        }
      case .Post:
        if fromCompleted {
          color = completedColor
        }
      case .Even:
        if fromCompleted && toCompleted {
          color = completedColor
        }
      }
    }
    self.connectionLayer?.strokeColor = color
  }
  
  func resetForMovement() {
    self.connectionLayer?.removeFromSuperlayer()
    self.connectionLayer = nil
  }
  
}