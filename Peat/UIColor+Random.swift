//
//  UIColor+Random.swift
//  Peat
//
//  Created by Matthew Barth on 2/1/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

extension NSNumber {
  static func randomCGFloat() -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UInt32.max)
  }
}

//extension UIColor {
//  static func randomColor() -> UIColor {
//    let r = NSNumber.randomCGFloat()
//    let g = NSNumber.randomCGFloat()
//    let b = NSNumber.randomCGFloat()
//    
//    // If you wanted a random alpha, just create another
//    // random number for that too.
//    return UIColor(red: r, green: g, blue: b, alpha: 1.0)
//  }
//}