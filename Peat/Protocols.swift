//
//  Protocols.swift
//  Peat
//
//  Created by Matthew Barth on 1/19/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


protocol TreeDelegate {
  func drawConnectionLayer(connection: CAShapeLayer)
  func fetchTreeData()
  func addLeafToScrollView(leafView: UIView)
  func drillIntoLeaf(leaf: Leaf)
}