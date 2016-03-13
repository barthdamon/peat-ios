//
//  Leaf.swift
//  Peat
//
//  Created by Matthew Barth on 10/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

protocol TreeObject {
  func viewForTree() -> UIView?
  func isSelected() -> Bool
  func objectId() -> String?
  func parentView() -> UIView?
  func changed(status: ChangeStatus)
  func isCompleted() -> Bool
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
  var paramGroupingId: String {
    if let id = grouping?.groupingId {
      return id
    } else {
      return ""
    }
  }
  
  //Admin
  var movingEnabled: Bool = false {
    didSet {
      togglePanActivation( movingEnabled )
    }
  }
  var isCurrentlyNew: Bool = false
  var connectionsEnabled: Bool = false {
    didSet {
      togglePanActivation( movingEnabled )
    }
  }
  var movingPanRecognizer: UIPanGestureRecognizer?
  
  // Leaf
  var ability: Ability?
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
  var tip: String?
  var abilityTitleLabel: UILabel?
  var groupingLabel: UILabel?
  
  var titleLabel: UILabel?
  var uploadsLabel: UILabel?
  
  //Locally Stored Variables
  var witnesses: Array<User>?
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
//    if let status = json["completionStatus"] as? String {
//      leaf.completionStatus = CompletionStatus(rawValue: status)
//    }
    leaf.timestamp = json["timestamp"] as? Int
    leaf.leafDescription = json["description"] as? String
    leaf.tip = json["tip"] as? String
    leaf.groupingId = json["groupingId"] as? String
    if let layout = json["layout"] as? jsonObject {
      if let coordinates = layout["coordinates"] as? jsonObject, x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        leaf.center = CGPoint(x: x, y: y)
      }
    }
    
    if let contents = json["contents"] as? jsonObject {
      if let jsonWitnesses = contents["witnesses"] as? Array<jsonObject> {
        leaf.witnesses = Array()
        for witness in jsonWitnesses {
          if let user = witness["witnessUser"] as? jsonObject {
            leaf.witnesses!.append(User.userFromProfile(user))
          }
        }
      }
      
      if let info = contents["mediaInfo"] as? Array<jsonObject> {
        for json in info {
          leaf.treeDelegate?.sharedStore().addMediaToStore(MediaObject.initWithJson(json, store: leaf.treeDelegate?.sharedStore()), publishImmediately: false)
        }
        leaf.getCompletionStatus()
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
  
  func setAbilityOnLeaf(ability: Ability) {
    self.ability = ability
    if let abilityName = ability.name, activityName = self.activityName {
      self.media?.forEach({ (object) -> () in
        object.activityName = activityName
        object.abilityName = abilityName
      })
    }
  }
  
  func params() -> jsonObject {
    return [
      "activityName" : paramFor(activityName),
      "leafId" : paramFor(leafId),
      "user_Id" : paramFor(user_Id),
      "ability_Id" : self.ability?._id != nil ? self.ability!._id! : "",
      "groupingId" : paramGroupingId,
      "layout" : [
        "coordinates" : [
          "x" : self.paramCenter?.x != nil ? String(self.paramCenter!.x) : "",
          "y" : self.paramCenter?.y != nil ? String(self.paramCenter!.y) : ""
        ]
      ],
      "completionStatus" : self.completionStatus != nil ? self.completionStatus!.rawValue : "",
      "abilityName" : self.ability?.name != nil ? self.ability!.name! : "",
      "tip" : paramFor(tip),
      "description" : paramFor(leafDescription)
    ]
  }
  
  func saveMedia(callback: (Bool) -> ()) {
    if let medias = self.media {
      for media in medias {
        if media.needsPublishing {
          media.publish("gallery/media", callback: callback)
          print("FOUND MEDIA THAT NEEDS PUBLISHING")
          //TODO: have the tree listen to the notification for when leaves are posted. Every time one is posted it goes through its leaves and if any are publishing, it checks somehow if any of their media is still publishing. probably need the media object in the notiication to check with that
          self.publishing = true
        } else {
          //doesnt need to be published
          callback(true)
        }
      }
    } else {
      //no media to save
      callback(true)
    }
  }
  
  func save(callback: (Bool) -> ()) {
    saveMedia() { (success) in
      if success {
        self.saveToServer(callback)
      } else {
        callback(false)
        print("Error posting media to server")
        //deal with error
      }
    }
  }
  
  func saveToServer(callback: (Bool) -> ()) {
    if changeStatus == .BrandNew {
      API.post(self.params(), url: "leaf/new", callback: { (res, err) in
        if let e = err {
          print("Error creating leaf: \(e)")
          callback(false)
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Leaf created: \(res)")
            self.changeStatus = .Unchanged
            if let json = res as? jsonObject {
              self.ability?._id = json["ability_Id"] as? String
            }
            self.getCompletionStatus()
            self.setLabels()
            self.treeDelegate?.checkForNewCompletions()
            callback(true)
          })
        }
      })
    } else {
      API.put(self.params(), url: "leaf/update", callback: { (res, err) in
        if let e = err {
          print("Error updating leaf \(e)")
          callback(false)
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Leaf updated: \(res)")
            self.changeStatus = .Unchanged
            self.getCompletionStatus()
            self.setLabels()
            self.treeDelegate?.checkForNewCompletions()
            callback(true)
          })
        }
      })
    }
  }
  
  func addGestureRecognizers() {
    if let view = self.view {
      
      let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "leafMoveInitiated:")
      doubleTapRecognizer.numberOfTapsRequired = 2
      doubleTapRecognizer.numberOfTouchesRequired = 1
      view.addGestureRecognizer(doubleTapRecognizer)
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: "leafDrilldownInitiated")
      tapRecognizer.numberOfTapsRequired = 1
      tapRecognizer.numberOfTouchesRequired = 1
      tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
      view.addGestureRecognizer(tapRecognizer)
      
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "leafConnectionsInitialized:")
      longPressRecognizer.minimumPressDuration = 1
      view.addGestureRecognizer(longPressRecognizer)
      
      //maybe when they tap a plus button and drag that adds a connection????
    }
  }
  
  func togglePanActivation( active: Bool ) {
    if active {
      movingPanRecognizer = UIPanGestureRecognizer(target: self, action: "leafBeingPanned:")
      self.view?.addGestureRecognizer(movingPanRecognizer!)
    } else if let pan = movingPanRecognizer {
      self.view?.removeGestureRecognizer(pan)
    }
  }
  
  func leafConnectionsInitialized(sender: UIGestureRecognizer) {
    let state = sender.state
    if state == .Changed || state == .Ended {
      leafBeingPanned(sender)
    } else {
      print("Leaf connections initialized")
      self.connectionsEnabled = true
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
                if let user = witness["witnessUser"] as? jsonObject {
                  self.witnesses!.append(User.userFromProfile(user))
                }
              }
            }

            if let info = json["mediaInfo"] as? jsonObject, mediaJson = info["media"] as? Array<jsonObject> {
              for json in mediaJson {
                self.treeDelegate?.sharedStore().addMediaToStore(MediaObject.initWithJson(json, store: self.treeDelegate?.sharedStore()), publishImmediately: false)
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
  
  func leafMoveInitiated(sender: UIGestureRecognizer) {
    treeDelegate?.sharedStore().treeStore.currentLeaves?.forEach({ (leaf) -> () in
      if leaf.leafId != self.leafId {
        leaf.movingEnabled = false
        leaf.deselectLeaf()
      }
    })
    treeDelegate?.sharedStore().treeStore.currentGroupings?.forEach({ (grouping) -> () in
      grouping.deselectGrouping()
    })
    self.movingEnabled = true
    self.drawLeafSelected()
//    if state == UIGestureRecognizerState.Changed {
//      leafBeingPanned(sender)
//    } else if state == UIGestureRecognizerState.Ended {
////      movingEnabled = false
////      deselectLeaf()
//    } else {
//      self.drawLeafSelected()
//      self.movingEnabled = true
//    }
//      treeDelegate?.drillIntoLeaf(self)
  }
  
  func leafBeingPanned(sender: UIGestureRecognizer) {
    print("Leaf being panned")
    let state = sender.state
    if state == UIGestureRecognizerState.Ended {
      print("Connections drawn ending")
      self.connectionsEnabled = false
      self.treeDelegate?.connectionsBeingDrawn(self, fromGrouping: nil, sender: sender)
    } else {
      if movingEnabled {
        self.treeDelegate?.leafBeingMoved(self, sender: sender)
      } else if connectionsEnabled {
        self.treeDelegate?.connectionsBeingDrawn(self, fromGrouping: nil, sender: sender)
      }
    }
  }
  
  func deselectLeaf() {
    if let view = self.view {
      self.isCurrentlyNew = false
      self.treeDelegate?.resetCurrentlyNew()
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
    self.isCurrentlyNew = false
    self.treeDelegate?.resetCurrentlyNew()
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
  
  func prepareForGrouping() {
    //remove all connections (totally delete them)
    //remove any connection with its id
    treeDelegate?.sharedStore().removeConnectionsForObject(self)
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
        setLabels()
        
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
  
  func setLabels() {
    if let view = self.view {
      let half = Leaf.standardHeight / 2
      if let name = self.ability?.name {
        var set = false
        if let _ = titleLabel {
          set = true
        } else {
          titleLabel = UILabel(frame: CGRectMake(0,0,Leaf.standardWidth, half))
        }
        titleLabel!.text = name
        if !set {
          titleLabel!.numberOfLines = 1
          titleLabel!.adjustsFontSizeToFitWidth = true
          view.addSubview(titleLabel!)
        }
      }
      
      var uploadsSet = false
      if let _ = uploadsLabel {
        uploadsSet = true
      } else {
        uploadsLabel = UILabel(frame: CGRectMake(0,half, Leaf.standardWidth, half))
      }
      let count = media != nil ? media!.count : 0
      uploadsLabel!.text = "\(count) uploads"
      if !uploadsSet {
        uploadsLabel!.numberOfLines = 1
        uploadsLabel!.textColor = UIColor.lightGrayColor()
        uploadsLabel!.adjustsFontSizeToFitWidth = true
        view.addSubview(uploadsLabel!)
      }
    }
  }
  
  func getCompletionStatus() {
    var status: CompletionStatus = .Goal
    if let media = self.media {
      media.forEach({ (media) -> () in
        if media.purpose == .Attempt || media.purpose == .Tutorial {
          status = .Uploaded
        }
      })
    }
    self.completionStatus = status
  }
  
  func viewForTree() -> UIView? {
    return self.view
  }
  
  func objectId() -> String? {
    return self.leafId
  }
  
  func isSelected() -> Bool {
    return self.movingEnabled
  }
  
  func isCompleted() -> Bool {
    return self.completionStatus == .Uploaded
  }
  
//  func containsPoint(point: CGPoint) -> Bool {
//    if let view = self.view {
//      if CGRectContainsPoint(view.bounds, point) {
//        return true
//      }
//    }
//    return false
//  }
  
  
}
