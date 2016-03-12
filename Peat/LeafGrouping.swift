//
//  LeafGrouping.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


class LeafGrouping: NSObject, TreeObject {
  
  var changeStatus: ChangeStatus = .Unchanged
  var name: String?
  var colorString: String?
  var activityName: String?
  
  var view: UIView?
  var user_Id: String?
  var groupingId: String?
  
  var center: CGPoint?
  var paramCenter: CGPoint? {
    return self.view != nil ? self.view!.center : center
  }
  var height: Int?
  var width: Int?
  
  var deleteButton: UIButton?
  var referenceFrame: CoordinatePair?
  
  var treeDelegate: TreeDelegate?
  var movingEnabled: Bool = false
  
  var rgbColor: UIColor? {
    didSet {
      self.colorString = rgbColor?.hexString()
    }
  }
  
  
  static func newGrouping(center: CGPoint, delegate: TreeDelegate) -> LeafGrouping {
    let newGrouping = LeafGrouping()
    newGrouping.center = center
    newGrouping.treeDelegate = delegate
    //generate random color
    newGrouping.groupingId = generateId()
    newGrouping.user_Id = CurrentUser.info.model?._id
    if let activity = delegate.getCurrentActivity(), name = activity.name {
      newGrouping.activityName = name
    }
    
    return newGrouping
  }
  
  static func initFromJson(json: jsonObject, delegate: TreeDelegate?) -> LeafGrouping {
    let grouping = LeafGrouping()
    grouping.treeDelegate = delegate
    grouping.user_Id = json["user_Id"] as? String
    grouping.name = json["name"] as? String
    grouping.groupingId = json["groupingId"] as? String
    grouping.activityName = json["activityName"] as? String
    
    if let layout = json["layout"] as? jsonObject {
      if let coordinates = layout["coordinates"] as? jsonObject, x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        grouping.center = CGPoint(x: x, y: y)
      }
      grouping.width = layout["width"] as? Int
      grouping.height = layout["height"] as? Int
    }
    grouping.colorString = json["colorString"] as? String
    if let colorString = grouping.colorString {
      grouping.rgbColor = UIColor.fromHex(colorString)
    }
    return grouping
  }
  
  func changed(status: ChangeStatus) {
    //Note: might break on server when updating a leaf that got removed before being created on server
    guard changeStatus == .BrandNew && status == .Updated else { changeStatus = status; return}
  }
  
  func params() -> Dictionary<String, AnyObject> {
    return [
      "user_Id": paramFor(user_Id),
      "groupingId": paramFor(groupingId),
      "activityName": paramFor(activityName),
      "name": paramFor(name),
      "colorString": paramFor(colorString),
      "layout" : [
        "coordinates" : [
          "x" : self.paramCenter?.x != nil ? String(self.paramCenter!.x) : "",
          "y" : self.paramCenter?.y != nil ? String(self.paramCenter!.y) : ""
        ],
        "width": paramFor(width),
        "height": paramFor(height)
      ]
    ]
  }
  
  //need a color slider and everything
  func updateGroupingColor(color: UIColor) {
    
  }
  
  func deselectGrouping() {
    if let view = self.view {
//      view.backgroundColor = UIColor.whiteColor()
      view.layer.shadowColor = UIColor.clearColor().CGColor
      view.layer.shadowOpacity = 0
      view.layer.shadowRadius = 0
      view.layer.shadowOffset = CGSizeMake(0, 0)
      view.layer.shadowRadius = 0
      //remove the delete button
      self.deleteButton?.removeFromSuperview()
    }
  }
  
  func drawGroupingSelected() {
    if let view = self.view {
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
  
  func drawGrouping() {
    if let center = center {
      referenceFrame = (x: center.x - Leaf.standardWidth, y: center.y - Leaf.standardHeight)
    }
    if let frame = referenceFrame {
      let frame = CGRectMake(frame.x, frame.y, Leaf.standardWidth * 3, Leaf.standardHeight * 3)
      view = UIView(frame: frame)
      if let view = self.view {
//        view.backgroundColor = UIColor.fromHex(colorString)

        if let color = self.rgbColor {
          view.backgroundColor = color
        } else {
          let randomColor = UIColor.randomColor()
          view.backgroundColor = randomColor
          self.rgbColor = randomColor
        }
        view.backgroundColor = self.rgbColor != nil ? self.rgbColor : UIColor.randomColor()
        view.layer.cornerRadius = 10
        //        view.backgroundColor = self.completionStatus ? UIColor.yellowColor() : UIColor.darkGrayColor()
        addGestureRecognizers()
        treeDelegate?.addGroupingToScrollView(self)
      }
    }
  }
  
  func addGestureRecognizers() {
    if let view = self.view {
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: "groupingBeingPlaced")
      tapRecognizer.numberOfTapsRequired = 1
      tapRecognizer.numberOfTouchesRequired = 1
      view.addGestureRecognizer(tapRecognizer)
      
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "groupingMoveInitiated:")
      longPressRecognizer.minimumPressDuration = 1
      view.addGestureRecognizer(longPressRecognizer)
      
      let movingPanRecognizer = UIPanGestureRecognizer(target: self, action: "groupingBeingPanned:")
      view.addGestureRecognizer(movingPanRecognizer)
      
      let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "newLeafInitiatedOnGrouping:")
      doubleTapRecognizer.numberOfTouchesRequired = 1
      doubleTapRecognizer.numberOfTapsRequired = 2
      
      view.addGestureRecognizer(doubleTapRecognizer)
      
      //maybe when they tap a plus button and drag that adds a connection????
    }
  }
  
  func newLeafInitiatedOnGrouping(sender: UITapGestureRecognizer) {
    self.treeDelegate?.addNewLeafToGrouping(self, sender: sender)
  }
  
  func groupingMoveInitiated(sender: UILongPressGestureRecognizer) {
    treeDelegate?.sharedStore().treeStore.currentLeaves?.forEach({ (leaf) -> () in
      leaf.deselectLeaf()
    })
    treeDelegate?.sharedStore().treeStore.currentGroupings?.forEach({ (grouping) -> () in
      if grouping.groupingId != self.groupingId {
        grouping.deselectGrouping()
      }
    })
    let state = sender.state
    if state == UIGestureRecognizerState.Changed {
      groupingBeingPanned(sender)
    } else if state == UIGestureRecognizerState.Ended {
      //      movingEnabled = false
      //      deselectLeaf()
    } else {
      self.drawGroupingSelected()
      self.movingEnabled = true
    }
  }
  
  func groupingBeingPlaced() {
    if movingEnabled {
      movingEnabled = false
      deselectGrouping()
    }
  }
  
  func deleteButtonPressed() {
    self.changeStatus = .Removed
    self.treeDelegate?.removeObjectFromView(self)
    treeDelegate?.sharedStore().removeConnectionsForObject(self)
  }

  
  func groupingBeingPanned(sender: UIGestureRecognizer) {
    if movingEnabled {
      self.treeDelegate?.groupingBeingMoved(self, sender: sender)
    } else {
      self.treeDelegate?.connectionsBeingDrawn(nil, fromGrouping: self, sender: sender)
    }
  }
  
  func viewForTree() -> UIView? {
    return self.view
  }
  
  func objectId() -> String? {
    return self.groupingId
  }
  
  func parentView() -> UIView? {
    return treeDelegate?.viewForTree()
  }
  
  func isSelected() -> Bool {
    return self.movingEnabled
  }
  
  func isCompleted() -> Bool {
    var status: CompletionStatus = .Goal
    if let view = self.view {
      for view in view.subviews {
        if let leaves = treeDelegate?.sharedStore().treeStore.currentLeaves {
          for leaf in leaves {
            if leaf.view == view && leaf.completionStatus == .Uploaded {
              status = .Uploaded
            }
          }
        }
      }
    }
    return status == .Uploaded
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