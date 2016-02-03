//
//  LeafGrouping.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


class LeafGrouping: NSObject {
  
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
    newGrouping.rgbColor = UIColor.redColor()
    newGrouping.groupingId = generateId()
    newGrouping.user_Id = CurrentUser.info.model?._id
    newGrouping.activityName = delegate.getCurrentActivity()
    
    return newGrouping
  }
  
  static func groupingFromJson(json: jsonObject) -> LeafGrouping {
    let grouping = LeafGrouping()
    grouping.name = json["name"] as? String
    grouping.colorString = json["colorString"] as? String
    if let layout = json["layout"] as? jsonObject {
      if let coordinates = layout["center"] as? jsonObject, x = coordinates["x"] as? Int, y = coordinates["y"] as? Int {
        grouping.center = CGPoint(x: x, y: y)
      }
    }
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
      "width": paramFor(width),
      "height": paramFor(height),
      "layout" : [
        "coordinates" : [
          "x" : self.paramCenter?.x != nil ? String(self.paramCenter!.x) : "",
          "y" : self.paramCenter?.y != nil ? String(self.paramCenter!.y) : ""
        ]
      ]
    ]
//    return [
//      "user_Id": self.user_Id != nil ? self.user_Id! : "",
//      "groupingId": self.groupingId != nil ? self.groupingId! : "",
//      "activityName": self.activityName != nil ? self.activityName! : "",
//      "name": self.name != nil ? self.name! : "",
//      "colorString": self.colorString != nil ? self.colorString! : "",
//      "width": self.width != nil ? String(self.width!) : "",
//      "height": self.height != nil ? String(self.height!) : "",
//      "layout" : [
//        "coordinates" : [
//          "x" : self.paramCenter?.x != nil ? String(self.paramCenter!.x) : "",
//          "y" : self.paramCenter?.y != nil ? String(self.paramCenter!.y) : ""
//        ]
//      ]
//    ]
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
  
  func drawGrouping(lowerLeaf: Leaf, highlightedLeaf: Leaf) {
    if let center = center {
      referenceFrame = (x: center.x - Leaf.standardWidth, y: center.y - Leaf.standardHeight)
    }
    if let frame = referenceFrame {
      let frame = CGRectMake(frame.x, frame.y, Leaf.standardWidth * 3, Leaf.standardHeight * 3)
      view = UIView(frame: frame)
      if let view = self.view {
//        view.backgroundColor = UIColor.fromHex(colorString)
        
        view.backgroundColor = UIColor.randomColor()
        view.layer.cornerRadius = 10
        //        view.backgroundColor = self.completionStatus ? UIColor.yellowColor() : UIColor.darkGrayColor()
        addGestureRecognizers()
        treeDelegate?.addGroupingToScrollView(self, lowerLeaf: lowerLeaf, higherLeaf: highlightedLeaf)
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
      
      //maybe when they tap a plus button and drag that adds a connection????
    }
  }
  
  func groupingMoveInitiated(sender: UILongPressGestureRecognizer) {
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

  
  func groupingBeingPanned(sender: UIGestureRecognizer) {
    if movingEnabled {
      self.treeDelegate?.groupingBeingMoved(self, sender: sender)
    } else {
      self.treeDelegate?.connectionsBeingDrawn(nil, fromGrouping: self, sender: sender)
    }
  }
  
  
  
}