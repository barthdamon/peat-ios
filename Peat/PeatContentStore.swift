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
  case Image = "image"
  case Video = "video"
  case Other = "other"
}

struct AbilityStore {
//  var storedActivities: Array<Activity>?
  var currentLeaves: Array<Leaf> = []
  
//  func findLeavesForActivity(activity: String) -> Array<LeafNode>? {
//    var returnLeaves: Array<LeafNode> = []
//    for leaf in leaves {
//      if leaf.activity == activity {
//        returnLeaves.append(leaf)
//      }
//    }
//    if returnLeaves.count > 0 {
//      return returnLeaves
//    } else {
//      return nil
//    }
//  }
  
}

typealias jsonObject = Dictionary<String, AnyObject>


//MARK: Content Store
private let _sharedStore = PeatContentStore()

class PeatContentStore: NSObject {
  
  var API = APIService.sharedService
  var mediaObjects: Array<MediaObject>?
  var abilityStore = AbilityStore()
  
  class var sharedStore: PeatContentStore {
    return _sharedStore
  }
  
  func getTreeData(activityName: String, delegate: TreeDelegate?, callback: APICallback) {
    API.get(nil, authType: .Token, url: "token/tree/\(activityName)"){ (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
        callback(nil, e)
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          print("TREE DATA: \(json)")
          if let treeInfo = json["treeInfo"] as? jsonObject, leaves = treeInfo["leaves"] as? Array<jsonObject> {
            self.abilityStore.currentLeaves = []
            for leaf in leaves {
              self.abilityStore.currentLeaves.append(Leaf.initWithJson(leaf, delegate: delegate))
            }
            callback(self.abilityStore.currentLeaves, nil)
          }
        }
      }
    }
  }

}


