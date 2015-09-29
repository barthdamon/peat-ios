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
  case Photo
  case Video
  case Other
  
  func toString() -> String {
    switch self {
    case .Photo:
      return "Photo"
    case .Video:
      return "Video"
    default:
      return "Other"
    }
  }
}

func convertToType(type :String) -> MediaType {
  switch type {
  case "Photo":
    return MediaType.Photo
  case "Video":
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
          self.createMediaObjects(json) { (res, err) -> () in
            self.populateMediaObjects() { (res, err) -> () in
              callback(res, err)
            }
          }
        }
      }
    }
  }
  
  func createMediaObjects(json :Dictionary<String, AnyObject>, callback: APICallback) {
    print("media query: \(json)")
    if let media = json["media"] {
      for var i = 0; i < media.count; i++ {
        if let selectedMedia = media[i] {
          let mediaObject = MediaObject()
          mediaObject.initWithJson(selectedMedia as! jsonObject)
          self.mediaObjects.append(mediaObject)
        }
      }
    }
  }
  
  func populateMediaObjects(callback :APICallback) {
    for var i = 0; i < mediaObjects.count; i++ {
      AWSContentHelper.sharedHelper.downloadPhoto(mediaObjects[i].mediaID!) { (res, err) -> () in
        if err != nil {
          callback(nil, err)
        } else {
          callback(true, err)
        }
      }
    }
  }


  
  
  
}



