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