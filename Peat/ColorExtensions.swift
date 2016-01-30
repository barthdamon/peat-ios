//
//  ColorExtensions.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

extension UIColor {

  func hexString() -> String {
    return self.hexString(false)
  }
  
  static func fromHex(string: String) -> UIColor {
    return UIColor(rgba: string)
  }
  //var hexString = UIColor.redColor().hexString(false) // "#FF0000"
  //var strokeColor = UIColor(rgba: "#ffcc00").CGColor // Solid color
}