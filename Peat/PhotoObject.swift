//
//  PhotoObject.swift
//  Peat
//
//  Created by Matthew Barth on 10/5/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class PhotoObject: MediaObject {
  
  var thumbnail: UIImage?
  var photoData: NSData?
  
  func photoWithJson(json: jsonObject) -> PhotoObject {
    let newPhoto = PhotoObject()
    newPhoto.initWithJson(json)
    return newPhoto
  }
  
  
}