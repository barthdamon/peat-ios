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
  func addLeafToScrollView(leafView: UIView)
}

typealias CoordinatePair = (x: CGFloat, y: CGFloat)

class LeafNode: NSObject {
  
  // Leaf Standards
  static let standardWidth: CGFloat = 100
  static let standardHeight: CGFloat = 50
  
  // Reference Variables for Drawing
  var referenceFrame: CoordinatePair?
  class var xOffset: CGFloat {
    return standardWidth / 2
  }
  class var yOffset: CGFloat {
    return standardHeight / 2
  }
  
  // Other
  var treeDelegate: TreeDelegate?
  var center: CGPoint?
  var view: UIView?
  
  
  // MARK: <<< Functions >>>
  init(coords: CoordinatePair, delegate: TreeDelegate) {
    super.init()
    self.treeDelegate = delegate
    center = CGPoint(x: coords.x, y: coords.y)
    generateBounds()
  }
  
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

  
  
  
}
