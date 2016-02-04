//
//  LeafConnection.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
class LeafConnection: NSObject {
  
  var _id: String?
  var changeStatus: ChangeStatus = .Unchanged
  var user_Id: String?
  var fromId: String?
  var toId: String?
  var type: LeafConnectionType?
  var activityName: String?
  
  var fromLeaf: Leaf? {
    didSet {
      fromId = fromLeaf?.leafId
    }
  }
  var toLeaf: Leaf? {
    didSet {
      toId = toLeaf?.leafId
    }
  }
  
  var treeDelegate: TreeDelegate?
  var connectionLayer: CAShapeLayer?
  
  static func newConnection(layer: CAShapeLayer, from: Leaf?, to: Leaf?, delegate: TreeDelegate) -> LeafConnection {
    let newConnection = LeafConnection()
    newConnection.fromLeaf = from
    newConnection.toLeaf = to
    newConnection.connectionLayer = layer
    newConnection.activityName = delegate.getCurrentActivity()
    return newConnection
  }
  
  static func initFromJson(json: jsonObject, delegate: TreeDelegate?) -> LeafConnection {
    let newConnection = LeafConnection()
    newConnection.treeDelegate = delegate
    newConnection.activityName = json["actiivtyName"] as? String
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
      "_id": paramFor(_id),
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