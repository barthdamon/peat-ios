//
//  TreeMath.swift
//  Peat
//
//  Created by Matthew Barth on 3/9/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


func normalize(vector: CGPoint) -> CGPoint {
  var nVector = CGPoint()
  let length = sqrt((vector.x * vector.x) + (vector.y * vector.y))
  nVector.x = vector.x / length
  nVector.y = vector.y / length
  return nVector
}

func dotProduct(a: CGPoint, b: CGPoint) -> CGFloat {
  return ( a.x * b.x ) + ( a.y * b.y )
//  let angle = atan2(vectorA.y, vectorA.x) - atan2(vectorB.y, vectorB.x)
}

extension Int {
  var degreesToRadians : CGFloat {
    return CGFloat(self) * CGFloat(M_PI) / 180.0
  }
}

extension UIView {
  func addDashedBorder() -> CAShapeLayer {
    let color = UIColor.cyanColor().CGColor
    
    let shapeLayer:CAShapeLayer = CAShapeLayer()
    let frameSize = self.frame.size
    let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
    
    shapeLayer.bounds = shapeRect
    shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
    shapeLayer.fillColor = UIColor.clearColor().CGColor
    shapeLayer.strokeColor = color
    shapeLayer.lineWidth = 2
    shapeLayer.lineJoin = kCALineJoinRound
    shapeLayer.lineDashPattern = [6,3]
    shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).CGPath
    
    self.layer.addSublayer(shapeLayer)
    return shapeLayer
  }
}