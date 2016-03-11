//
//  LeafConnection.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
class LeafConnection: NSObject {
  
  var connectionId: String?
  var changeStatus: ChangeStatus = .Unchanged
  var user_Id: String?
  var fromId: String?
  var toId: String?
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
  var arrow: UIImageView?
  
  static func newConnection(layer: CAShapeLayer, arrow: UIImageView?, from: TreeObject?, to: TreeObject?, delegate: TreeDelegate) -> LeafConnection {
    let newConnection = LeafConnection()
    newConnection.user_Id = CurrentUser.info.model?._id
    newConnection.arrow = arrow
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
      "fromId": paramFor(fromId)
    ]
  }
  
  func resetForMovement() {
    self.connectionLayer?.removeFromSuperlayer()
    self.connectionLayer = nil
  }
  
}