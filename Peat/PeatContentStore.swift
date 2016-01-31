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
  var currentLeaves: Array<Leaf>?
  var currentConnections: Array<LeafConnection>?
  var currentMediaObjects: Array<MediaObject>?
  var selectedLeaf: Leaf?
  var activityName: String?
  
  var changedLeaves: Set<Leaf>?
  
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
    self.currentLeaves = Array()
    self.currentMediaObjects = nil
    self.selectedLeaf = nil
  }
  
  func treeParams() -> jsonObject {
    if let leaves = self.changedLeaves, name = self.activityName {
      var updates: Array<jsonObject> = []
      var removals: Array<jsonObject> = []
      var newLeaves: Array<jsonObject> = []
      for leaf in leaves {
        if leaf.deleted {
          removals.append(leaf.params())
        } else if leaf.brandNew {
          newLeaves.append(leaf.params())
        } else {
          updates.append(leaf.params())
        }
      }
      let params: jsonObject = ["activityName" : name, "newLeaves" : newLeaves, "updated" : updates, "removed" : removals]
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
  var leaves: Array<Leaf> {
    return treeStore.currentLeaves != nil ? treeStore.currentLeaves! : []
  }
  
  class var sharedStore: PeatContentStore {
    return _sharedStore
  }
  
  func getTreeData(delegate: TreeDelegate?, viewing: User?, callback: (Bool) -> () ) {
    self.treeStore.activityName = "Snowboarding"
    if let activityName = treeStore.activityName {
      var viewing_Id: [String: AnyObject]? = nil
      if let viewing = viewing, id = viewing._id {
        viewing_Id = ["viewing": "\(id)"]
      }
      API.get(viewing_Id, authType: .Token, url: "tree/\(activityName)"){ (res, err) -> () in
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
                self.treeStore.currentLeaves!.append(Leaf.initWithJson(leaf, delegate: delegate))
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
  func leafWithId(leafId: String) -> Leaf? {
    if let currentLeaves = self.treeStore.currentLeaves {
      for leaf in currentLeaves {
        if leaf.leafId == leafId {
          return leaf
        }
      }
    }
    return nil
  }
  
  func setSelectedLeaf(leaf: Leaf) {
    self.treeStore.selectedLeaf = leaf
  }
  
  func leafChanged(leaf: Leaf) {
    if let _ = self.treeStore.changedLeaves {
      self.treeStore.changedLeaves!.insert(leaf)
    } else {
      self.treeStore.changedLeaves = Set()
      self.treeStore.changedLeaves!.insert(leaf)
    }
  }
  
  func addLeafToStore(leaf: Leaf) {
    if let _ = self.treeStore.currentLeaves {
      self.treeStore.currentLeaves!.append(leaf)
    } else {
      self.treeStore.currentLeaves = Array()
      self.treeStore.currentLeaves!.append(leaf)
    }
  }
  
  func addMediaToStore(media: MediaObject) {
    if let _ = self.treeStore.currentMediaObjects {
    } else {
      self.treeStore.currentMediaObjects = Array()
    }
    self.treeStore.currentMediaObjects!.append(media)
  }
  
  func addConnection(connection: LeafConnection) {
    if let _ = self.treeStore.currentConnections {
    } else {
      self.treeStore.currentConnections = Array()
    }
    self.treeStore.currentConnections!.append(connection)
  }
  
  func removeCollection(connection: LeafConnection) {
    if let _ = self.treeStore.currentConnections {
//      self.treeStore.currentConnections!.remove(connection)
    }
  }
  
  func findConnection(from: Leaf?, to: Leaf?) -> LeafConnection? {
    if let from = from, to = to {
      if let currentConnections = self.treeStore.currentConnections {
        for connection in currentConnections {
          if connection.toId == to.leafId && connection.fromId == from.leafId {
            return connection
          }
        }
      }
    }
    return nil
  }
  
  func newConnection(connectionLayer: CAShapeLayer, from: Leaf?, to: Leaf?) {
//    if let existingConnection = findConnection(from, to: to) {
//      existingConnection.connectionLayer = connectionLayer
//    } else {
      let newConnection = LeafConnection.newConnection(connectionLayer, from: from, to: to)
      self.addConnection(newConnection)
//    }
  }
  
}


