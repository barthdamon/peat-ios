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
  var url: NSURL?
  
  func initWithJson(json: jsonObject) {
    if let id = json["mediaID"] as? String, user = json["user"] as? String, timestamp = json["timestamp"] as? String, type = json["mediaType"] as? String, url = json["url"] as? String {
      self.mediaID = id
      self.user = user
      self.timeStamp = timestamp
      self.url = NSURL(string: url)
      self.mediaType = convertToType(type)
    }
  }
  
//  func generateImageForMedia() {
//    AWSContentHelper.sharedHelper.ge(mediaID!) { (res, err) in
//      if err != nil {
//        print("Error downloading Image")
//      } else {
//        if let image = res as? UIImage {
//          self.thumbnail = image
//        }
//      }
//    }
//  }
  
}