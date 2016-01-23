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
  var filePath: NSURL?
  var madeLocal: Bool = false
  
  var API = APIService.sharedService
  
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
  
  static func initFromUploader(leaf: Leaf?, type: MediaType?, thumbnail: UIImage?, filePath: NSURL?) -> MediaObject {
    let media = MediaObject()
    media.leafId = leaf?.leafId
    media.mediaType = type
    media.thumbnail = thumbnail
    media.filePath = filePath
    media.madeLocal = true
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
  
  func params() -> jsonObject {
//    ["mediaInfo": ["mediaID": mediaId, "url" : url, "mediaType": type.rawValue], "leaf": leafId, "meta": ["leafPath": leafPath, "description": description]]
          let url = "https://s3.amazonaws.com/peat-assets/\(mediaId)"
//    return [
//      "activityName" : self.treeDelegate!.getCurrentActivity(),
//      "leafId" : self.leafId!,
//      "layout" : [
//        "coordinates" : [
//          "x" : self.center?.x != nil ? String(self.center!.x) : "",
//          "y" : self.center?.y != nil ? String(self.center!.y) : "",
//        ],
//        "connections" : "",
//        "groupings" : ""
//      ],
//      "completionStatus" : self.completionStatus != nil ? self.completionStatus!.rawValue : "",
//      "title" : self.title != nil ? self.title! : "",
//      "description" : self.details != nil ? self.details! : ""
//    ]
//    user_Id: req.user._id,
//    mediaId: mediaId,
//    leafId: leafId,
//    mediaInfo: {
//      url: req.body.mediaInfo.url,
//      mediaType: req.body.mediaInfo.mediaType
//    },
//    description: req.body.description,
//    location: req.body.location,
//    timestamp: currentTime
    return ["":""]
  }
  
  func addCommentsToMedia(json: jsonObject) {
    
  }
  
  func publish() {
    if let type = self.mediaType, filePath = self.filePath {
      let typeExtension = type == .Video ? ".mov" : ".img"
      let id = generateId()
      self.mediaId = "\(id)\(typeExtension)"
      if let id = self.mediaId {
        AWSContentHelper.sharedHelper.postMediaFromFactory(filePath, mediaID: id, mediaType: type) { (res, err) in
          if err != nil {
            print(err)
          } else {
            self.sendToServer()
          }
        }
      }
    }
  }
  
  func sendToServer() {
    API.post(self.params(), authType: HTTPRequestAuthType.Token, url: "media") { (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          print(json)
        }
      }
    }
  }
  
}