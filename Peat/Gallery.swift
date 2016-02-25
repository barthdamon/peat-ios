//
//  Gallery.swift
//  Peat
//
//  Created by Matthew Barth on 2/21/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

class ActivityTag: NSObject {
  var activityName: String?
  var activity: Activity?
  
  var mediaIds: Array<String>?
  var mediaObjects: Array<MediaObject>?
  
  static func initFromJson(json: jsonObject) -> ActivityTag {
    let newTag = ActivityTag()
    newTag.activityName = json["activityName"] as? String
    newTag.mediaIds = json["mediaIds"] as? Array<String>
    return newTag
  }
}

class Gallery: NSObject {
  var user_Id: String?
  //unused:
  var activityTags: Array<ActivityTag>?
  
  var mediaObjects: Array<MediaObject>?
  
  var API = APIService.sharedService
  var store: PeatContentStore?
  
  convenience init(store: PeatContentStore) {
    self.init()
    self.store = store
  }
  
  func initializeGallery(user_Id: String, callback: (Bool) ->()) {
    API.get(nil, authType: .Token, url: "gallery/\(user_Id)") { (res, err) -> () in
      if let e = err {
        print("error getting gallery: \(e)")
        callback(false)
      } else {
        print("Gallery Recieved")
        if let json = res as? jsonObject {
          self.initFromJson(json)
          callback(true)
        }
      }
    }
  }
  
  func initFromJson(json: jsonObject) {
    
    self.user_Id = json["user_Id"] as? String
//    if let activityTagJson = json["activityTags"] as? Array<jsonObject> {
//      self.activityTags = []
//      activityTagJson.forEach({ (activity) -> () in
//        self.activityTags!.append(ActivityTag.initFromJson(json))
//      })
//    }
    print("GALLERY JSON: \(json)")
    if let info = json["mediaInfo"] as? jsonObject, mediaObjectJson = info["media"] as? Array<jsonObject> {
      self.mediaObjects = []
      mediaObjectJson.forEach({ (mediaJson) -> () in
        self.mediaObjects!.append(MediaObject.initWithJson(mediaJson, store: nil))
      })
    }
    
  }
  
  //this is only called when uploaded from the gallery. Uploading on the tree will upload to gallery on its own
  func saveMediaToGallery(media: MediaObject) {
    if media.needsPublishing {
      if let _ = self.mediaObjects {
      } else {
        self.mediaObjects = Array()
      }
      if !self.mediaObjects!.contains(media) {
        self.mediaObjects!.append(media)
        //post to server
        media.publish { (success) -> () in
          if success {
            print("Media uploaded to gallery successfully")
            //show the
          } else {
            print("Failure uploading media from gallery")
          }
        }
      }
    }
  }
  
}