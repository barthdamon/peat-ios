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
  func changed(status: ChangeStatus)
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
  
  var ability: Ability?
  
  // Leaf
  var treeDelegate: TreeDelegate?
  var view: UIView?
  var deleteButton: UIButton?
  var _id: String?
  var user_Id: String?
  var leafId: String?
  var activityName: String?
  var completionStatus: CompletionStatus?
  var timestamp: Int?
  var leafDescription: String?
  var movingEnabled: Bool = false
  var tip: String?
  
  var abilityTitleLabel: UILabel?
  var groupingLabel: UILabel?
  
  //Locally Stored Variables
  var witnesses: Array<Witness>?
  var publishing: Bool = false
  
  var media: Array<MediaObject>? {
    return treeDelegate?.sharedStore().treeStore.mediaForLeaf(self)
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
    leaf.ability = Ability.abilityFromLeaf(json)
    leaf.activityName = json["activityName"] as? String
    if let status = json["completionStatus"] as? String {
      leaf.completionStatus = CompletionStatus(rawValue: status)
    }
    leaf.timestamp = json["timestamp"] as? Int
    leaf.leafDescription = json["description"] as? String
    leaf.tip = json["tip"] as? String
    
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
    if let activity = delegate.getCurrentActivity(), name = activity.name {
      newLeaf.activityName = name
    }
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
      "ability_Id" : self.ability?._id != nil ? self.ability!._id! : "",
      "layout" : [
        "coordinates" : [
          "x" : self.paramCenter?.x != nil ? String(self.paramCenter!.x) : "",
          "y" : self.paramCenter?.y != nil ? String(self.paramCenter!.y) : ""
        ],
        "groupingId" : paramFor(paramGroupingId),
      ],
      "completionStatus" : self.completionStatus != nil ? self.completionStatus!.rawValue : "",
      "abilityName" : self.ability?.name != nil ? self.ability!.name! : "",
      "tip" : paramFor(tip),
      "description" : paramFor(leafDescription)
    ]
  }
  
  func saveMedia() {
    if let medias = self.media {
      for media in medias {
        if media.needsPublishing {
          media.ability_Id = self.ability?._id
          media.publish()
          media.needsPublishing = false
          print("FOUND MEDIA THAT NEEDS PUBLISHING")
          //TODO: have the tree listen to the notification for when leaves are posted. Every time one is posted it goes through its leaves and if any are publishing, it checks somehow if any of their media is still publishing. probably need the media object in the notiication to check with that
          self.publishing = true
        }
      }
    }
  }
  
  func save(callback: (Bool) -> ()) {
    saveMedia()
    if changeStatus == .BrandNew {
      API.post(self.params(), url: "leaf/new", callback: { (res, err) in
        if let e = err {
          print("Error creating leaf: \(e)")
          callback(false)
        } else {
          print("Leaf created: \(res)")
          self.changeStatus = .Unchanged
          if let json = res as? jsonObject {
            self.ability?._id = json["ability_Id"] as? String
          }
          self.saveMedia()
          callback(true)
        }
      })
    } else {
      API.put(self.params(), url: "leaf/update", callback: { (res, err) in
        if let e = err {
          print("Error updating leaf \(e)")
          callback(false)
        } else {
          print("Leaf updated: \(res)")
          self.saveMedia()
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
    if let _ = treeDelegate?.sharedStore().treeStore.mediaForLeaf(self) {callback(true); return}
    if let leafId = leafId {
      API.get(nil, url: "leaves/\(leafId)"){ (res, err) -> () in
        if let e = err {
          print("error: \(e)")
        } else {
          if let json = res as? jsonObject {
            print("LEAF DATA: \(json)")
            if let jsonWitnesses = json["witnesses"] as? Array<jsonObject> {
              self.witnesses = Array()
              for witness in jsonWitnesses {
                self.witnesses!.append(Witness.initFromJson(witness))
              }
            }

            if let info = json["mediaInfo"] as? jsonObject, mediaJson = info["media"] as? Array<jsonObject> {
              for json in mediaJson {
                self.treeDelegate?.sharedStore().addMediaToStore(MediaObject.initWithJson(json, store: self.treeDelegate?.sharedStore()))
              }
              self.getCompletionStatus()
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
    self.treeDelegate?.removeObjectFromView(self)
    //remove any connection with its id
    treeDelegate?.sharedStore().removeConnectionsForObject(self)
  }
  
  func findGrouping() {
    if let groupingId = self.groupingId, delegate = treeDelegate {
      for grouping in delegate.sharedStore().groupings {
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
        treeDelegate?.sharedStore().addLeafToStore(self)
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
  
  func getCompletionStatus() {
    var status: CompletionStatus = .Goal
    media?.forEach({ (media) -> () in
      if media.purpose == .Attempt && status == .Goal {
        status = .Learning
      }
      if media.purpose == .Completion {
        status = .Completed
      }
    })
    self.completionStatus = status
  }
  
  func viewForTree() -> UIView? {
    return self.view
  }
  
  func objectId() -> String? {
    return self.leafId
  }
  
  
}
