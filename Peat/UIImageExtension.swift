//
//  UIImageExtension.swift
//  Peat
//
//  Created by Matthew Barth on 12/7/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

extension UIImage {
  
  // Loads image asynchronously
  class func loadAsync(url: NSURL, callback: (UIImage)->()) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
      
      let imageData = NSData(contentsOfURL: url)
      if let data = imageData {
        dispatch_async(dispatch_get_main_queue(), {
          if let image = UIImage(data: data) {
            callback(image)
          }
        })
      }
    })
  }
}