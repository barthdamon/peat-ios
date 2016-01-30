//
//  LeafConnection.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
class LeafConnection: NSObject {
  
  var fromId: String?
  var toId: String?
  var type: LeafConnectionType?
  
  var fromLeaf: Leaf? {
    didSet {
      fromId = fromLeaf!.leafId
    }
  }
  var toLeaf: Leaf? {
    didSet {
      toId = toLeaf!.leafId
    }
  }
  
  var connectionLayer: CAShapeLayer?
  
  static func newConnection(layer: CAShapeLayer, from: Leaf, to: Leaf) -> LeafConnection {
    let newConnection = LeafConnection()
    newConnection.fromLeaf = from
    newConnection.toLeaf = to
    newConnection.connectionLayer = layer
    return newConnection
  }
  
}