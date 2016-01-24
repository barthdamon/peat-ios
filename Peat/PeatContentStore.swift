//
//  PeatContentStore.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

enum MediaType: String {
  case Image = "Image"
  case Video = "Video"
  case Other = "Other"
}

struct TreeStore {
//  var storedActivities: Array<Activity>?
  var currentLeaves: Set<Leaf>?
  var currentMediaObjects: Set<MediaObject>?
  var selectedLeaf: Leaf?
  var activityName: String?
  
  var comments: Array<Comment>?
  
  func mediaForLeaf(leaf: Leaf) -> Array<MediaObject>? {
    var leafMedia: Array<MediaObject> = []
    if let leafId = leaf.leafId, mediaObjects = currentMediaObjects {
      for media in mediaObjects {
        if let id = media.leafId {
          if id == leafId {
            leafMedia.append(media)
          }
        }
      }
    }
    return leafMedia.count > 0 ? leafMedia : nil
  }
  
  mutating func resetStore() {
    self.currentLeaves = Set()
    self.currentMediaObjects = nil
    self.selectedLeaf = nil
  }
  
  func treeParams() -> jsonObject {
    if let leaves = self.currentLeaves, name = self.activityName {
      var leafParams: Array<jsonObject> = []
      for leaf in leaves {
        leafParams.append(leaf.params())
      }
      let params: jsonObject = ["activityName" : name, "leaves": leafParams]
      print("PARAMS FOR TREE SAVE: \(params)")
      return params
    } else {
      return ["":""]
    }
  }
  
}

typealias jsonObject = Dictionary<String, AnyObject>


//MARK: Content Store
private let _sharedStore = PeatContentStore()

class PeatContentStore: NSObject {
  
  var API = APIService.sharedService
  var mediaObjects: Array<MediaObject>?
  var treeStore = TreeStore()
  var leaves: Set<Leaf> {
    return treeStore.currentLeaves != nil ? treeStore.currentLeaves! : []
  }
  
  class var sharedStore: PeatContentStore {
    return _sharedStore
  }
  
  func getTreeData(delegate: TreeDelegate?, callback: (Bool) -> () ) {
    self.treeStore.activityName = "Snowboarding"
    if let activityName = treeStore.activityName {
      API.get(nil, authType: .Token, url: "tree/\(activityName)"){ (res, err) -> () in
        if let e = err {
          print("Error:\(e)")
          callback(false)
        } else {
          if let json = res as? Dictionary<String, AnyObject> {
            print("TREE DATA: \(json)")
            if let treeInfo = json["treeInfo"] as? jsonObject, leaves = treeInfo["leaves"] as? Array<jsonObject> {
              //reset the store, data for new tree incoming
              self.treeStore.resetStore()
              for leaf in leaves {
                self.treeStore.currentLeaves!.insert(Leaf.initWithJson(leaf, delegate: delegate))
              }
              callback(true)
            }
          }
        }
      }
    }
  }
  
  func syncTreeChanges(callback: (Bool) -> ()) {

    if let name = treeStore.activityName {
      API.put(treeStore.treeParams(), authType: .Token, url: "tree/\(name)/update"){ (res, err) -> () in
        if let e = err {
          print("Error:\(e)")
          callback(false)
        } else {
          callback(true)
        }
      }
    }
  }
  
  
  
  
  //MARK: Helpers
  func setSelectedLeaf(leaf: Leaf) {
    self.treeStore.selectedLeaf = leaf
  }
  
  func addLeafToStore(leaf: Leaf) {
    if let _ = self.treeStore.currentLeaves {
      self.treeStore.currentLeaves!.insert(leaf)
    } else {
      self.treeStore.currentLeaves = Set()
      self.treeStore.currentLeaves!.insert(leaf)
    }
  }
  
  func addMediaToStore(media: MediaObject) {
    if let _ = self.treeStore.currentMediaObjects {
      self.treeStore.currentMediaObjects!.insert(media)
    } else {
      self.treeStore.currentMediaObjects = Set()
      self.treeStore.currentMediaObjects!.insert(media)
    }
  }
  
}


