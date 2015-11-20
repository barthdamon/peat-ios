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
enum Activity: String, CustomStringConvertible {
  case Trampoline = "trampoline"
  case Snowboarding = "snowboarding"
  
  var description: String {
    return self.rawValue
  }
}

func parseActivity(activity: String) -> Activity {
  switch activity {
  case "trampoline":
    return .Trampoline
  case "snowboarding":
    return .Snowboarding
  default:
    return .Trampoline
  }
}

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
  var mediaObjects: Array<MediaObject>?
  var leaves: Array<LeafNode>?
  
  class var sharedStore: PeatContentStore {
    return _sharedStore
  }

  
//MARK: MEDIA & NEWSFEED
  func initializeNewsfeed(callback: APICallback) {
    print("INITIALIZING NEWSFEED")
    
    APIService.sharedService.get(nil, url: "media") { (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
        callback(nil, e)
      } else {
        if let json = res as? jsonObject {
          self.createMediaObjects(json) { (res, err) -> () in
            if err != nil {
              print("error creating objects")
              callback(nil, err)
            } else {
              if let mediaObjects = res as? Array<MediaObject> {
                self.mediaObjects = mediaObjects
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
    //TODO: need to add a check for if the update limit exceeds 5 and doesn't match up against the most recent otherwise you will miss data basically
    //send down a timestamp along with media object, thats what you send up here. Media objects need timestamps so that we can sort through for any new stuff
    if let mostRecent = self.mediaObjects?[0].timeStamp {
      APIService.sharedService.post(["mostRecent" : mostRecent], authType: .Token, url: "media/update") { (res, err) -> () in
        if let e = err {
          print("error: \(e)")
          callback(nil, e)
        } else {
          if let json = res as? jsonObject {
            self.createMediaObjects(json) { (res, err) -> () in
              if err != nil {
                print("Error creating objects")
                callback(nil, err)
              } else {
                if var updatedObjects = res as? Array<MediaObject> {
                  //prepend the new objects to mediaObjects array
                  if let _ = self.mediaObjects {
                    updatedObjects += self.mediaObjects!
                    self.mediaObjects?.removeAll()
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
  }
  
  func extendNewsfeed(callback: APICallback) {
    if let lastRecieved = self.mediaObjects?.last?.timeStamp {
      APIService.sharedService.post(["lastRecieved" : lastRecieved], authType: .Token, url: "media/extend") { (res, err) -> () in
        if let e = err {
          print("error: \(e)")
          callback(nil, e)
        } else {
          if let json = res as? jsonObject {
            self.createMediaObjects(json) { (res, err) -> () in
              if err != nil {
                print("Error creating objects")
                callback(nil, err)
              } else {
                if let extendedObjects = res as? Array<MediaObject> {
                  if let _ = self.mediaObjects {
                    self.mediaObjects! += extendedObjects
                    callback(self.mediaObjects!, nil)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  
  func createMediaObjects(json :jsonObject, callback: APICallback) {
//    print("media query: \(json)")
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
      //Done on server:
//      newMediaObjects.sortInPlace({ (a, b) -> Bool in
//        return a.timeStamp > b.timeStamp
//      })
      callback(newMediaObjects, nil)
    }
  }
  
  
  
//MARK: LEAVES
  func generateActivityTree(activity: Activity, delegate: TreeDelegate) {
    API.post(["activity" : "trampoline"], authType: .Token, url: "leaves/get") { (res, err) in
      if let e = err {
        print(e)
        NSNotificationCenter.defaultCenter().postNotificationName("errorfetchingTreeData", object: self, userInfo: nil)
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          self.populateLeaves(json, delegate: delegate)
        }
      }
    }
  }
  
  func populateLeaves(json: jsonObject, delegate: TreeDelegate) {
    if let leaves = json["leaves"] as? Array<jsonObject> {
      self.leaves = []
      for leaf in leaves {
        let newleaf = LeafNode()
        newleaf.initWithJson(leaf, delegate: delegate)
        self.leaves?.append(newleaf)
      }
    NSNotificationCenter.defaultCenter().postNotificationName("leavesPopulated", object: self, userInfo: nil)
    }
  }
  
  func findLeafWithId(id: String) -> LeafNode? {
    if let leaves = self.leaves {
      for leaf in leaves {
        if leaf.id == id {
          return leaf
        }
      }
    }
    return nil
  }
  
}



