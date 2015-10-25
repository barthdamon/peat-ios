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
enum MediaType: String, CustomStringConvertible {
  case Image = "image"
  case Video = "video"
  case Other = "other"
  
  var description: String{
    return self.rawValue
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

  
  //MARK: NEWSFEED INITIALIZERS
  func initializeNewsfeed(callback: APICallback) {
    print("INITIALIZING NEWSFEED")
    
    APIService.sharedService.get(nil, url: "media") { (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
      } else {
        if let json = res as? jsonObject {
          self.createMediaObjects(json) { (res, err) -> () in
            if err != nil {
              print("error creating objects")
            } else {
              if let mediaObjects = res as? Array<MediaObject> {
                self.mediaObjects += mediaObjects
                callback(self.mediaObjects, nil)
              }
            }
          }
        }
      }
    }
  }
  
  func updateNewsfeed(callback: APICallback) {
    print("UPDATING NEWSFEED")
    //send down a timestamp along with media object, thats what you send up here. Media objects need timestamps so that we can sort through for any new stuff
    if let mostRecent = self.mediaObjects[0].timeStamp {
      APIService.sharedService.post(["mostRecent" : mostRecent], authType: .Token, url: "media/update") { (res, err) -> () in
        if let e = err {
          print("error: \(e)")
        } else {
          if let json = res as? jsonObject {
            self.createMediaObjects(json) { (res, err) -> () in
              if err != nil {
                print("Error creating objects")
              } else {
                if let mediaObjects = res as? Array<MediaObject> {
                  //prepend the new objects to mediaObjects array
                  var updatedObjects = mediaObjects
                  updatedObjects += self.mediaObjects
                  self.mediaObjects = updatedObjects
                  callback(self.mediaObjects, nil)
                }
              }
            }
          }
        }
      }
    }
  }
  
  func extendNewsfeed() {
    
  }
  
  //MARK NEWSFEED CONTENT CREATION
  
  func createMediaObjects(json :jsonObject, callback: APICallback) {
    print("media query: \(json)")
    //append to new media objects, then send callback to functions. Have this function be unbiased for extend, initialize, and update
    var newMediaObjects: Array<MediaObject> = []
    
    if let media = json["media"] as? Array<jsonObject> {
      for selectedMedia: jsonObject in media {
        if let type = selectedMedia["mediaType"] as? String {
          var mediaObject = MediaObject()
          if type == "video" {
            mediaObject = VideoObject().videoWithJson(selectedMedia)
//            self.videoObjects.append(mediaObject as! VideoObject)
          } else if type == "image" {
            mediaObject = PhotoObject().photoWithJson(selectedMedia)
//            self.photoObjects.append(mediaObject as! PhotoObject)
          }
          newMediaObjects.append(mediaObject)
        }
      }
      callback(newMediaObjects, nil)
    }
  }
  
  
}



