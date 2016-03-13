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
  var currentConnections: Set<LeafConnection>?
  var currentGroupings: Set<LeafGrouping>?
  
  var currentMediaObjects: Set<MediaObject>?
  var selectedLeaf: Leaf?
  var currentActivity: Activity? {
    didSet {
      resetStore()
    }
  }
  
  var comments: Set<Comment>?
  
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
    self.currentGroupings = Set()
    self.currentConnections = Set()
    self.currentMediaObjects = nil
    self.selectedLeaf = nil
  }
  
  mutating func treeParams() -> jsonObject {
    
    var updatedLeaves: Array<jsonObject> = []
    var removedLeaves: Array<jsonObject> = []
    var newLeaves: Array<jsonObject> = []
    
    var updatedConnections: Array<jsonObject> = []
    var removedConnections: Array<jsonObject> = []
    var newConnections: Array<jsonObject> = []
    
    var updatedGroupings: Array<jsonObject> = []
    var removedGroupings: Array<jsonObject> = []
    var newGroupings: Array<jsonObject> = []
    
    if let name = self.currentActivity?.name {
      
      if let leaves = currentLeaves {
        for leaf in leaves {
          switch leaf.changeStatus {
          case .Updated:
             updatedLeaves.append(leaf.params())
          case .Removed:
            removedLeaves.append(leaf.params())
          case .BrandNew:
            newLeaves.append(leaf.params())
          case .Unchanged:
            break
          }
        }
      }
      
      if let groupings = currentGroupings {
        for grouping in groupings {
          switch grouping.changeStatus {
          case .Updated:
            updatedGroupings.append(grouping.params())
          case .Removed:
            removedGroupings.append(grouping.params())
          case .BrandNew:
            newGroupings.append(grouping.params())
          case .Unchanged:
            break
          }
        }
      }
      
      if let connections = currentConnections {
        for connection in connections {
          switch connection.changeStatus {
          case .Updated:
            updatedConnections.append(connection.params())
          case .Removed:
            removedConnections.append(connection.params())
          case .BrandNew:
            newConnections.append(connection.params())
          case .Unchanged:
            break
          }
        }
      }
      //NOTE: there should never be any New Leaves sent
      let params: jsonObject = ["activityName" : name, "updatedLeaves" : updatedLeaves, "removedLeaves" : removedLeaves, "newLeaves" : newLeaves, "updatedConnections" : updatedConnections, "removedConnections": removedConnections, "newConnections" : newConnections, "updatedGroupings" : updatedGroupings, "removedGroupings": removedGroupings, "newGroupings" : newGroupings]
      print("PARAMS FOR TREE SAVE: \(params)")
      return params
    } else {
      return ["":""]
    }
  }
  
}

typealias jsonObject = Dictionary<String, AnyObject>
typealias TreeContent = (vc: TreeViewController, store: TreeStore)

//MARK: Content Store
//private let _sharedStore = PeatContentStore()

class PeatContentStore: NSObject {
  var API = APIService.sharedService
  
  var gallery = Gallery()
  var treeStore = TreeStore()
  
  var leaves: Set<Leaf> {
    return treeStore.currentLeaves != nil ? treeStore.currentLeaves! : Set()
  }
  var groupings: Set<LeafGrouping> {
    return treeStore.currentGroupings != nil ? treeStore.currentGroupings! : Set()
  }
  var connections: Set<LeafConnection> {
    return treeStore.currentConnections != nil ? treeStore.currentConnections! : Set()
  }
  
//  class var sharedStore: PeatContentStore {
//    return _sharedStore
//  }
//  
//  func saveToStores(vc: TreeViewController) {
//    for var i = 0; i < pastStores.count; i++ {
//      if pastStores[i].vc == vc {
//        pastStores[i].store = treeStore
//        return
//      }
//    }
//    pastStores.append((vc: vc, store: treeStore))
//  }
//  
//  func setCurrentStore() {
//    
//  }
  
  func getTreeData(delegate: TreeDelegate?, viewing: User?, activity: Activity?, callback: (Bool) -> () ) {
    self.treeStore.currentActivity = activity
    if let activityName = treeStore.currentActivity?.name, _id = CurrentUser.info.model?._id {
      var viewing_Id = _id
      if let viewing = viewing, _id = viewing._id {
        viewing_Id = _id
      }
      API.get(nil, authType: .Token, url: urlEncoded("tree/\(activityName)/\(viewing_Id)")){ (res, err) -> () in
        if let e = err {
          print("Error:\(e)")
          callback(false)
        } else {
          if let json = res as? Dictionary<String, AnyObject> {
//            print("TREE DATA: \(json)")
            if let leaves = json["leaves"] as? Array<jsonObject> {
              //reset the store, data for new tree incoming
              self.treeStore.resetStore()
              for leaf in leaves {
                self.treeStore.currentLeaves!.insert(Leaf.initWithJson(leaf, delegate: delegate))
              }
            }
            
            if let connections = json["connections"] as? Array<jsonObject> {
              for connection in connections {
                self.treeStore.currentConnections!.insert(LeafConnection.initFromJson(connection, delegate: delegate))
              }
            }
            
            if let groupings = json["groupings"] as? Array<jsonObject> {
              for grouping in groupings {
                self.treeStore.currentGroupings!.insert(LeafGrouping.initFromJson(grouping, delegate: delegate))
              }
            }
            
            callback(true)
          }
        }
      }
    }
  }
  
  func syncTreeChanges(callback: (Bool) -> ()) {
    if let activity = treeStore.currentActivity, name = activity.name {
      API.put(treeStore.treeParams(), authType: .Token, url: "tree/\(name)/update"){ (res, err) -> () in
        if let e = err {
          print("Error:\(e)")
          callback(false)
        } else {
          CurrentUser.info.model?.newActiveActivity(activity)
          self.resetTreeChanges()
          callback(true)
        }
      }
    }
  }
  
  func resetTreeChanges() {
    for leaf in leaves {
      leaf.changeStatus = .Unchanged
    }
  
    for grouping in groupings {
      grouping.changeStatus = .Unchanged
    }
  
    for connection in connections {
      connection.changeStatus = .Unchanged
    }
  }
  
  func searchForAbilities(activityName: String, abilityTerm: String, callback: (Array<Ability>?) -> () ) {
    let url = "abilities/\(activityName)/\(abilityTerm)"
    print("URL: FOR ABILITY: \(url)")
    API.get(nil, authType: .Token, url: urlEncoded("abilities/\(activityName)/\(abilityTerm)")) { (res, err) -> () in
      if let e = err {
        print("Error searching abilites: \(e)")
        callback(nil)
      } else {
        if let json = res as? jsonObject, abilityJson = json["abilities"] as? Array<jsonObject> {
          var abilities: Array<Ability> = []
          for ability in abilityJson {
            abilities.append(Ability.abilityFromJson(ability))
          }
          print("Abilities found: \(abilities)")
          callback(abilities)
        }
      }
    }
  }
  
  func searchForActivities(user: User, activityTerm: String, callback: (Array<Activity>?) -> () ) {
    API.get(nil, authType: .Token, url: urlEncoded("activities/\(activityTerm)")) { (res, err) -> () in
      if let e = err {
        print("Error searching abilites: \(e)")
        callback(nil)
      } else {
        if let json = res as? jsonObject, activityJson = json["activities"] as? Array<jsonObject> {
          var activities: Array<Activity> = []
          for activity in activityJson {
            activities.append(Activity.activityFromJson(activity))
          }
          print("Activities found: \(activities)")
          callback(activities)
        }
      }
    }
  }
  
  func getLeafFeed(leaf: Leaf, callback: (Dictionary<String, AnyObject>?) -> () ) {
    if let abilityName = leaf.ability?.name, activityName = treeStore.currentActivity?.name {
      API.get(nil, authType: .Token, url: urlEncoded("news/leaf/\(activityName)/\(abilityName)")) { (res, err) -> () in
        if let e = err {
          print("Error searching abilites: \(e)")
          callback(nil)
        } else {
          print("RES: \(res)")
          var leafFeed: Array<MediaObject> = []
          var leafTutorials: Array<MediaObject> = []
          if let json = res as? jsonObject {
            if let feed = json["leafFeed"] as? jsonObject, mediaJson = feed["media"] as? Array<jsonObject> {
              for media in mediaJson {
                leafFeed.append(MediaObject.initWithJson(media, store: self))
              }
            }
            if let tutorials = json["leafTutorials"] as? jsonObject, mediaJson = tutorials["media"] as? Array<jsonObject> {
              for media in mediaJson {
                leafTutorials.append(MediaObject.initWithJson(media, store: self))
              }
            }
            callback(["leafFeed": leafFeed, "leafTutorials": leafTutorials])
          } else {
            callback(nil)
          }
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
  
//  func leafChanged(leaf: Leaf) {
//    if let _ = self.treeStore.changedLeaves {
//      self.treeStore.changedLeaves!.insert(leaf)
//    } else {
//      self.treeStore.changedLeaves = Set()
//      self.treeStore.changedLeaves!.insert(leaf)
//    }
//  }
  
  func addLeafToStore(leaf: Leaf) {
    if let _ = self.treeStore.currentLeaves {
      self.treeStore.currentLeaves!.insert(leaf)
    } else {
      self.treeStore.currentLeaves = Set()
      self.treeStore.currentLeaves!.insert(leaf)
    }
  }
  
  func addMediaToStore(media: MediaObject, publishImmediately: Bool) {
    if let _ = self.treeStore.currentMediaObjects {
    } else {
      self.treeStore.currentMediaObjects = Set()
    }
    self.treeStore.currentMediaObjects!.insert(media)
    //adds to the gallery objects as well
    self.gallery.saveMediaToGallery(media, publishImmediately: publishImmediately)
  }
  
  func addConnection(connection: LeafConnection) {
    if let _ = self.treeStore.currentConnections {
    } else {
      self.treeStore.currentConnections = Set()
    }
    self.treeStore.currentConnections!.insert(connection)
  }
  
  func removeConnection(connection: LeafConnection) {
    if let _ = self.treeStore.currentConnections {
      self.treeStore.currentConnections!.remove(connection)
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
  
  func newConnection(connectionLayer: CAShapeLayer, arrow: UIImageView?, from: TreeObject?, to: TreeObject?, delegate: TreeDelegate) {
//    if let existingConnection = findConnection(from, to: to) {
//      existingConnection.connectionLayer = connectionLayer
//    } else {
    let newConnection = LeafConnection.newConnection(connectionLayer, arrow: arrow, from: from, to: to, delegate: delegate)
      self.addConnection(newConnection)
//    }
  }
  
  func addGroupingToStore(grouping: LeafGrouping) {
    if let _ = self.treeStore.currentGroupings {
      self.treeStore.currentGroupings!.insert(grouping)
    } else {
      self.treeStore.currentGroupings = Set()
      self.treeStore.currentGroupings!.insert(grouping)
    }
  }
  
  func attachObjectsToConnection(connection: LeafConnection) {
    if let fromId = connection.fromId, toId = connection.toId {
      for leaf in leaves {
        if leaf.leafId == toId {
          connection.toObject = leaf
        }
        if leaf.leafId == fromId {
          connection.fromObject = leaf
        }
      }
      for grouping in groupings {
        if grouping.groupingId == toId { connection.toObject = grouping }
        if grouping.groupingId == fromId { connection.fromObject = grouping }
      }
    }
  }
  
  func checkForExistingLeaf(from: TreeObject, to: TreeObject) -> Bool {
    var found = false
    for connection in self.connections {
      if let fromId = connection.fromId, toId = connection.toId {
        if (fromId == from.objectId() && toId == to.objectId()) || (fromId == to.objectId() && toId == from.objectId()) {
          found = true
        }
      }
    }
    return found
  }
  
  func removeConnectionsForObject(object: TreeObject) {
    if let connections = treeStore.currentConnections {
      connections.forEach({ (connection) -> () in
        if connection.fromId == object.objectId() || connection.toId == object.objectId() {
          connection.connectionLayer?.removeFromSuperlayer()
          if let arrow = connection.arrow {
            arrow.removeFromSuperview()
          }
          treeStore.currentConnections?.remove(connection)
        }
      })
    }
  }
  
}
