//
//  MediaObject.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class MediaObject: NSObject {
  
  var mediaType: MediaType?
  var mediaID: String?
  var user: String?
  var timeStamp: String?
  var thumbnail: UIImage?
  
  func initWithJson(json: jsonObject) {
    if let id = json["mediaID"] as? String, user = json["user"] as? String, timestamp = json["timestamp"] as? String, type = json["mediaType"] as? String {
      self.mediaID = id
      self.user = user
      self.timeStamp = timestamp
      self.mediaType = convertToType(type)
    }
  }
  
  func generateImageForMedia() {
    
  }
  
}