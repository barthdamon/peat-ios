//
//  Leaf.swift
//  Peat
//
//  Created by Matthew Barth on 10/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

protocol TreeObject {
  func viewForTree() -> UIView?
  func objectId() -> String?
  func parentView() -> UIView?
}

import Foundation
import UIKit

typealias CoordinatePair = (x: CGFloat, y: CGFloat)

class Leaf: NSObject, TreeObject {
  
  var changeStatus: ChangeStatus = .Unchanged
  
  // Leaf Standards
  static let standardWidth: CGFloat = 100
  static let standardHeight: CGFloat = 50
  
  // Reference Variables
  var referenceFrame: CoordinatePair?
  class var xOffset: CGFloat {
    return standardWidth / 2
  }
  class var yOffset: CGFloat {
    return standardHeight / 2
  }
  // Unique Drawing Variables
  var center: CGPoint?
  var groupingCenter: CGPoint?
  
  var paramCenter: CGPoint? {
    return self.view != nil ? self.view!.center : center
  }
  var grouping: LeafGrouping?
  var groupingId: String?
  var paramGroupingId: String? {
    return grouping?.groupingId
  }
  
  // Leaf
  var treeDelegate: TreeDelegate?
  var view: UIView?
  var deleteButton: UIButton?
  var _id: String?
  var user_Id: String?
  var leafId: String?
  var activityName: String?
  var completionStatus: CompletionStatus?
  var title: String?
  var timestamp: Int?
  var leafDescription: String?
  var movingEnabled: Bool = false
  
  var abilityTitleLabel: UILabel?
  var groupingLabel: UILabel?
  
  var media: Array<MediaObject>? {
    return PeatContentStore.sharedStore.treeStore.mediaForLeaf(self)
  }
  
  //Contents (media, comments, likes, follows)
//  var media: [MediaObject]?
//  var comments: [Comment]?
  //need likes, follows, and witnesses as well......
  
  var API = APIService.sharedService
  
// MARK: INITIALIZATION
  static func initWithJson(json: jsonObject, delegate: TreeDelegate?) -> Leaf {
    let leaf = Leaf()
    leaf.treeDelegate = delegate
    leaf._id = json["_id"] as? String
    leaf.user_Id = json["user_Id"] as? String
    leaf.leafId = json["leafId"] as? String
    leaf.activityName = json["activityName"] as? String
    if let status = json["completionStatus"] as? String {
      leaf.completionStatus = CompletionStatus(rawValue: status)
    }
    leaf.timestamp = json["timestamp"] as? Int
    leaf.leafDescription = json["description"] as? String
    leaf.title = json["title"] as? String
    
    if let layout = json["layout"] as? jsonObject {
      leaf.groupingId = layout["groupingId"] as? String
      if let coordinates = layout["coordinates"] as? jsonObject, x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        leaf.center = CGPoint(x: x, y: y)
      }
    }
    return leaf
  }
  
  static func initFromTree(center: CGPoint, delegate: TreeDelegate) -> Leaf {
    let newLeaf = Leaf()
    newLeaf.center = center
    newLeaf.treeDelegate = delegate
    newLeaf.changeStatus = .BrandNew
    newLeaf.leafId = generateId()
    newLeaf.user_Id = CurrentUser.info.model?._id
    newLeaf.activityName = delegate.getCurrentActivity()
    return newLeaf
  }
  
  func changed(status: ChangeStatus) {
    //Note: might break on server when updating a leaf that got removed before being created on server
    guard changeStatus == .BrandNew && status == .Updated else { changeStatus = status; return}
  }
  
  func params() -> jsonObject {
    return [
      "activityName" : paramFor(activityName),
      "leafId" : paramFor(leafId),
      "user_Id" : paramFor(user_Id),
      "layout" : [
        "coordinates" : [
          "x" : self.paramCenter?.x != nil ? String(self.paramCenter!.x) : "",
          "y" : self.paramCenter?.y != nil ? String(self.paramCenter!.y) : ""
        ],
        "groupingId" : paramFor(paramGroupingId),
      ],
      "completionStatus" : self.completionStatus != nil ? self.completionStatus!.rawValue : "",
      "title" : paramFor(title),
      "description" : paramFor(leafDescription)
    ]
  }
  
  func save(callback: (Bool) -> ()) {
    if changeStatus == .BrandNew {
      API.post(self.params(), url: "leaf/new", callback: { (res, err) in
        if let e = err {
          print("Error creating leaf: \(e)")
          callback(false)
        } else {
          print("Leaf created: \(res)")
          self.changeStatus = .Unchanged
          callback(true)
        }
      })
    } else {
      API.put(self.params(), url: "leaf/update", callback: { (res, err) in
        if let e = err {
          print("Error updating leaf \(e)")
          callback(false)
        } else {
          print("Leaf created: \(res)")
          callback(true)
        }
      })
    }
  }
  
  func addGestureRecognizers() {
    if let view = self.view {
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: "leafDrilldownInitiated")
      tapRecognizer.numberOfTapsRequired = 1
      tapRecognizer.numberOfTouchesRequired = 1
      view.addGestureRecognizer(tapRecognizer)
      
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "leafMoveInitiated:")
      longPressRecognizer.minimumPressDuration = 1
      view.addGestureRecognizer(longPressRecognizer)
      
      let movingPanRecognizer = UIPanGestureRecognizer(target: self, action: "leafBeingPanned:")
      view.addGestureRecognizer(movingPanRecognizer)
      
      //maybe when they tap a plus button and drag that adds a connection????
    }
  }
  
  func setDelegate(delegate: TreeDelegate) {
    self.treeDelegate = delegate
  }
  
  func fetchContents(callback: (Bool) -> ()) {
    if let _ = PeatContentStore.sharedStore.treeStore.mediaForLeaf(self) {callback(true); return}
    if let leafId = leafId {
      API.get(nil, url: "tree/leaves/\(leafId)"){ (res, err) -> () in
        if let e = err {
          print("error: \(e)")
        } else {
          if let json = res as? jsonObject {
            print("LEAF DATA: \(json)")
            if let witnesses = json["witnesses"] as? Array<jsonObject> {
              print(witnesses)
              //add witnesses to store
            }

            if let info = json["mediaInfo"] as? jsonObject, mediaJson = info["media"] as? Array<jsonObject> {
              for objectJson in mediaJson {
                PeatContentStore.sharedStore.addMediaToStore(MediaObject.initWithJson(objectJson))
              }
            }
            
            if let comments = json["comments"] as? Array<jsonObject> {
              print(comments)
              //add commnts to store
            }

          }
        }
        callback(true)
      }
    } else {
      callback(false)
    }
  }
  
  func leafMoveInitiated(sender: UILongPressGestureRecognizer) {
    let state = sender.state
    if state == UIGestureRecognizerState.Changed {
      leafBeingPanned(sender)
    } else if state == UIGestureRecognizerState.Ended {
//      movingEnabled = false
//      deselectLeaf()
    } else {
      self.drawLeafSelected()
      self.movingEnabled = true
    }
  }
  
  func leafBeingPanned(sender: UIGestureRecognizer) {
    if movingEnabled {
      self.treeDelegate?.leafBeingMoved(self, sender: sender)
    } else {
      self.treeDelegate?.connectionsBeingDrawn(self, fromGrouping: nil, sender: sender)
    }
  }
  
  func deselectLeaf() {
    if let view = self.view {
      self.movingEnabled = false
      view.backgroundColor = UIColor.whiteColor()
      view.layer.shadowColor = UIColor.clearColor().CGColor
      view.layer.shadowOpacity = 0
      view.layer.shadowRadius = 0
      view.layer.shadowOffset = CGSizeMake(0, 0)
      view.layer.shadowRadius = 0
      //remove the delete button
      self.deleteButton?.removeFromSuperview()
    }
  }
  
  func drawLeafSelected() {
    if let view = self.view {
//      view.layer.borderColor = UIColor.darkGrayColor().CGColor
//      view.layer.borderWidth = 2
      view.backgroundColor = UIColor.yellowColor()
      view.layer.shadowColor = UIColor.darkGrayColor().CGColor
      view.layer.shadowOpacity = 0.8
      view.layer.shadowRadius = 3.0
      view.layer.shadowOffset = CGSizeMake(7, 7)
      
      //add a delete button and save it as a var on leaf
      self.deleteButton = UIButton(frame: CGRectMake(0,0,15,15))
      deleteButton?.setBackgroundImage(UIImage(named: "cancel"), forState: .Normal)
      deleteButton?.addTarget(self, action: "deleteButtonPressed", forControlEvents: .TouchUpInside)
      self.view?.addSubview(self.deleteButton!)
    }
  }
  
  func deleteButtonPressed() {
    self.changeStatus = .Removed
    self.treeDelegate?.removeLeafFromView(self)
  }
  
  func findGrouping() {
    if let groupingId = self.groupingId {
      for grouping in PeatContentStore.sharedStore.groupings {
        if grouping.groupingId == groupingId {
          self.grouping = grouping
        }
      }
    }
  }
  
  func generateBounds() {
    if let center = center {
      referenceFrame = (x: center.x - Leaf.xOffset, y: center.y - Leaf.yOffset)
      createFrame()
    }
  }
  
  func createFrame() {
    if let frame = referenceFrame {
      let frame = CGRectMake(frame.x, frame.y, Leaf.standardWidth, Leaf.standardHeight)
      view = UIView(frame: frame)
      if let view = self.view {
        view.backgroundColor = UIColor.whiteColor()
        view.layer.cornerRadius = 10
//        view.backgroundColor = self.completionStatus ? UIColor.yellowColor() : UIColor.darkGrayColor()
        addGestureRecognizers()
//        drawGrouping()
        if let grouping = self.grouping {
          treeDelegate?.addLeafToGrouping(self, grouping: grouping)
        } else {
          treeDelegate?.addLeafToScrollView(self)
        }
        PeatContentStore.sharedStore.addLeafToStore(self)
      }
    }
  }
  
  func leafDrilldownInitiated() {
    if movingEnabled {
      movingEnabled = false
      deselectLeaf()
//      treeDelegate?.checkForOverlaps(self)
    } else {
      treeDelegate?.drillIntoLeaf(self)
    }
  }
  
  func parentView() -> UIView? {
    if let grouping = grouping, groupingView = grouping.view {
      return groupingView
    } else if let treeView = treeDelegate?.viewForTree() {
      return treeView
    } else {
      return nil
    }
  }
  
  func viewForTree() -> UIView? {
    return self.view
  }
  
  func objectId() -> String? {
    return self.leafId
  }
  
  
}
