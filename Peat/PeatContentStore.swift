//
//  PeatContentStore.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit


//MARK: General Typealiases
enum MediaType {
  case Image
  case Video
  case Other
  
  func toString() -> String {
    switch self {
    case .Image:
      return "image"
    case .Video:
      return "video"
    default:
      return "other"
    }
  }
}

func convertToType(type :String) -> MediaType {
  switch type {
  case "image":
    return MediaType.Image
  case "video":
    return MediaType.Video
  default:
    return MediaType.Other
  }
}

typealias jsonObject = Dictionary<String, AnyObject>


//MARK: Content Store
private let _sharedStore = PeatContentStore()

class PeatContentStore: NSObject {
  
  var API = APIService.sharedService
  var mediaObjects: Array<MediaObject> = []
  var photoObjects: Array<PhotoObject> = []
  var videoObjects: Array<VideoObject> = []
  
  class var sharedStore: PeatContentStore {
    return _sharedStore
  }

  
  //MARK: NEWSFEED CONTENT
  func initializeNewsfeed(callback: APICallback) {
    print("INITIALIZING NEWSFEED")
    
    APIService.sharedService.get(nil, url: "media") { (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          self.createMediaObjects(json) { (res) -> () in
            if res == "error" {
              print("error fetching")
            } else {
              callback(json, nil)
            }
          }
        }
      }
    }
  }
  
  func createMediaObjects(json :Dictionary<String, AnyObject>,  callback: (String?) -> () ) {
    print("media query: \(json)")
    if let media = json["media"] {
      for var i = 0; i < media.count; i++ {
        if let selectedMedia = media[i] as? jsonObject {
          if let type = selectedMedia["mediaType"] as? String {
            var mediaObject = MediaObject()
            if type == "video" {
              mediaObject = VideoObject().videoWithJson(selectedMedia)
              self.videoObjects.append(mediaObject as! VideoObject)
            } else {
              mediaObject = PhotoObject().photoWithJson(selectedMedia)
              self.photoObjects.append(mediaObject as! PhotoObject)
            }
            self.mediaObjects.append(mediaObject)
            callback("no error")
          }
        }
      }
    }
  }
  
  func downloadVideoContent() {
    AWSContentHelper.sharedHelper.downloadVideos(videoObjects) { (objects) in
      if let objects = objects {
        self.videoObjects = objects
        NSNotificationCenter.defaultCenter().postNotificationName("videoObjectsPopulated", object: self, userInfo: nil)
      } else {
        print("Error fetching video objects")
        NSNotificationCenter.defaultCenter().postNotificationName("videoObjectsFailedToPopulate", object: self, userInfo: nil)
      }
    }
  }

  func generateMediaThumbnails() {
    AWSContentHelper.sharedHelper.generateThumbnails(photoObjects) { (objects) in
      if objects == nil {
        print("Error downloading Image")
        NSNotificationCenter.defaultCenter().postNotificationName("mediaObjectsFailedToPopulate", object: self, userInfo: nil)
      } else {
        self.photoObjects = objects!
        NSNotificationCenter.defaultCenter().postNotificationName("mediaObjectsPopulated", object: self, userInfo: nil)
      }
    }
  }


  
  
  
}



