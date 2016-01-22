//
//  MediaObject.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class MediaObject: NSObject {
  
  //parsed
  var _id: String?
  var user_Id: String?
  var mediaId: String?
  var leafId: String?
  var mediaDescription: String?
  var location: String?
  var timestamp: Int?
  var url: NSURL?
  var mediaType: MediaType?
  
  //created
  var thumbnail: UIImage?
  
  static func initWithJson(json: jsonObject) -> MediaObject {
    let media = MediaObject()
    
    media._id = json["_id"] as? String
    media.user_Id = json["user_Id"] as? String
    media.mediaId = json["mediaId"] as? String
    media.leafId = json["leafId"] as? String
    media.mediaDescription = json["description"] as? String
    media.location = json["location"] as? String
    media.timestamp = json["timestamp"] as? Int
    if let info = json["mediaInfo"] as? jsonObject, url = info["url"] as? String, mediaType = info["mediaType"] as? String {
      media.url = NSURL(string: url)
      media.mediaType = MediaType(rawValue: mediaType)
    }
    
    return media
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
  
  func addCommentsToMedia(json: jsonObject) {
    
  }
  
}