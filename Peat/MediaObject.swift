//
//  MediaObject.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class MediaObject: NSObject {
  
  var id: String?
  var mediaType: MediaType?
  var mediaID: String?
  var user: String?
  var timeStamp: Double?
  var datePosted: NSDate?
  var url: NSURL?
  var mediaDescription: String?
  var leafPath: String?
  var leafId: String?
  var thumbnail: UIImage?
  
  func initWithJson(json: jsonObject) {
    
    //mediaInfo
    if let mediaInfo = json["mediaInfo"] as? jsonObject, mediaId = mediaInfo["mediaID"] as? String, url = mediaInfo["url"] as? String, type = mediaInfo["mediaType"] as? String {
      self.url = NSURL(string: url)
      self.mediaType = MediaType(rawValue: type)
      self.mediaID = mediaId
    }
    
    //general
    if let id = json["_id"] as? String, user = json["user"] as? String, leaf = json["leaf"] as? String {
      self.id = id
      self.user = user
      self.leafId = leaf
    }
    
    //meta
    if let meta = json["meta"] as? jsonObject, timestamp = meta["timestamp"] as? Double, leafPath = meta["leafPath"] as? String, description = meta["description"] as? String {
      self.timeStamp = timestamp
      self.datePosted = NSDate(timeIntervalSince1970: timestamp)
      self.mediaDescription = description
      self.leafPath = leafPath
    }
    
  }
  
  func generateThumbnail(media: MediaObject, callback: (UIImage?, NSError?) -> () ) {
    if let url = media.url {
      if let thumbnail = media.thumbnail {
        callback(thumbnail, nil)
      } else {
        if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
          media.thumbnail = image
          callback(image, nil)
        }
      }
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