//
//  LeafGrouping.swift
//  Peat
//
//  Created by Matthew Barth on 1/29/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


class LeafGrouping: NSObject, TreeObject, UITextFieldDelegate, UIGestureRecognizerDelegate {
  
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
  static let standardHeight: CGFloat = Leaf.standardHeight * 3
  static let standardWidth: CGFloat = Leaf.standardWidth * 3
  var height: CGFloat?
  var width: CGFloat?
  
  var deleteButton: UIButton?
  var referenceFrame: CoordinatePair?
  
  var treeDelegate: TreeDelegate?
  var movingEnabled: Bool = false
  var connectionsEnabled: Bool = false
  
  var dragView: UIImageView?
  var expandEnabled: Bool = false
  var titleField: UITextField?
  
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
    newGrouping.width = LeafGrouping.standardWidth
    newGrouping.height = LeafGrouping.standardHeight
    
    return newGrouping
  }
  
  static func initFromJson(json: jsonObject, delegate: TreeDelegate?) -> LeafGrouping {
    let grouping = LeafGrouping()
    grouping.treeDelegate = delegate
    grouping.user_Id = json["user_Id"] as? String
    grouping.name = json["name"] as? String
    grouping.groupingId = json["groupingId"] as? String
    grouping.activityName = json["activityName"] as? String
    grouping.width = json["width"] as? CGFloat
    grouping.height = json["height"] as? CGFloat
    
    if let layout = json["layout"] as? jsonObject {
      if let coordinates = layout["coordinates"] as? jsonObject, x = coordinates["x"] as? CGFloat, y = coordinates["y"] as? CGFloat {
        grouping.center = CGPoint(x: x, y: y)
      }
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
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
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
          "x" : self.paramCenter?.x != nil ? self.paramCenter!.x : 0,
          "y" : self.paramCenter?.y != nil ? self.paramCenter!.y : 0
        ],
      ],
      "width": width != nil ? width! : LeafGrouping.standardWidth,
      "height": height != nil ? height! : LeafGrouping.standardHeight
    ]
  }
  
  //need a color slider and everything
  func updateGroupingColor(color: UIColor) {
    
  }
  
  func deselectGrouping() {
    if let view = self.view {
      togglePanActivation(false)
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
      togglePanActivation(true)
      //add a delete button and save it as a var on leaf
      self.deleteButton = UIButton(frame: CGRectMake(0,0,15,15))
      deleteButton?.setBackgroundImage(UIImage(named: "cancel"), forState: .Normal)
      deleteButton?.addTarget(self, action: "deleteButtonPressed", forControlEvents: .TouchUpInside)
      self.view?.addSubview(self.deleteButton!)
    }
  }
  
  func drawGrouping() {
    if let center = center, width = width, height = height {
      referenceFrame = (x: center.x - width / 2, y: center.y - height / 2)
    }
    if let frame = referenceFrame, width = width, height = height {
      let frame = CGRectMake(frame.x, frame.y, width, height)
      view = UIView(frame: frame)
      view?.clipsToBounds = true
      if let view = self.view {
//        view.backgroundColor = UIColor.fromHex(colorString)
        configureDragView()
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
  
  func configureDragView() {
    if let view = self.view, width = width, height = height {
      dragView = UIImageView(frame: CGRectMake(width - 30, height - 30, 15, 15))
      dragView!.backgroundColor = UIColor.blackColor()
      
      let dragRecognizer = UIPanGestureRecognizer(target: self, action: "dragButtonPressed:")
      dragView!.addGestureRecognizer(dragRecognizer)
      dragView!.userInteractionEnabled = true
      view.addSubview(dragView!)
      
      titleField = UITextField(frame: CGRectMake(width - 200, height - 30, 150, 25))
      if let title = self.name where title != "" {
        titleField!.text = title
      } else {
        titleField!.text = "Grouping Title"
      }
      titleField!.adjustsFontSizeToFitWidth = true
      titleField!.backgroundColor = UIColor.clearColor()
      titleField!.textAlignment = .Right
      titleField!.delegate = self
      if let delegate = self.treeDelegate {
        titleField!.hidden = delegate.isHidingText()
      }
      view.addSubview(titleField!)
    }
  }
  
  func textFieldShouldClear(textField: UITextField) -> Bool {
    if let title = self.name {
      titleField?.text = title
    } else {
      titleField?.text = "Grouping Title"
    }
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.titleField?.resignFirstResponder()
    self.name = textField.text
    self.treeDelegate?.changesMade()
    self.changeStatus = .Updated
    return true
  }

  
  func dragButtonPressed(sender: UIGestureRecognizer) {
    print("Expand enabled")
    let finger = sender.locationInView(self.view)
    if sender.state == UIGestureRecognizerState.Ended {
      expandEnabled = false
    } else {
      expandEnabled = true
//      self.view?.layer.borderWidth = 5
//      self.view?.layer.borderColor = UIColor.blackColor().CGColor
      changed(.Updated)
      self.treeDelegate?.changesMade()
      if let view = self.view, dragView = dragView {
        let x = view.frame.minX
        let y = view.frame.minY
        let area = finger.x * finger.y
        if area > LeafGrouping.standardWidth * LeafGrouping.standardHeight {
          view.frame = CGRectMake(x, y, finger.x, finger.y)
          dragView.frame = CGRectMake(view.frame.width - 30, view.frame.height - 30, 15, 15)
          titleField?.frame = CGRectMake(view.frame.width - 200, view.frame.height - 30, 150, 25)
          self.width = finger.x
          self.height = finger.y
        }
      }
    }
  }
  
  func dragButtonReleased() {
    print("expand enabled")
    expandEnabled = false
  }
  
  func addGestureRecognizers() {
    if let view = self.view {
      
      
      let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "groupingMoveInitiated:")
      doubleTapRecognizer.numberOfTapsRequired = 2
      doubleTapRecognizer.numberOfTouchesRequired = 1
      view.addGestureRecognizer(doubleTapRecognizer)
      
//      let tapRecognizer = UITapGestureRecognizer(target: self, action: "leafDrilldownInitiated")
//      tapRecognizer.numberOfTapsRequired = 1
//      tapRecognizer.numberOfTouchesRequired = 1
//      tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
//      view.addGestureRecognizer(tapRecognizer)
//      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "groupingMoveInitiated:")
//      longPressRecognizer.minimumPressDuration = 1
//      view.addGestureRecognizer(longPressRecognizer)
      
      let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "groupingConnectionsInitialized:")
      longPressRecognizer.minimumPressDuration = 1
      view.addGestureRecognizer(longPressRecognizer)
      
      
      let tapRecognizer = UITapGestureRecognizer(target: self, action: "groupingBeingPlaced")
      tapRecognizer.numberOfTapsRequired = 1
      tapRecognizer.numberOfTouchesRequired = 1
      view.addGestureRecognizer(tapRecognizer)
      

      
      //need to add and remove this dynamically based on the long press so that scrolling can be reenambled when not drawing connectons
      
//      let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "newLeafInitiatedOnGrouping:")
//      doubleTapRecognizer.numberOfTouchesRequired = 1
//      doubleTapRecognizer.numberOfTapsRequired = 2
      
      view.addGestureRecognizer(doubleTapRecognizer)
      
      //maybe when they tap a plus button and drag that adds a connection????
    }
  }
  
  func groupingConnectionsInitialized(sender: UIGestureRecognizer) {
    let state = sender.state
    if state == .Changed || state == .Ended {
      print("Connections being drawn")
      groupingBeingPanned(sender)
      if state == .Ended {
        print("Connections drawn ending")
        connectionsEnabled = false
        togglePanActivation(false)
      }
    } else {
      print("Leaf connections initialized")
      self.connectionsEnabled = true
      togglePanActivation(true)
    }
  }
  
  func togglePanActivation( active: Bool) {
    if active {
      let movingPanRecognizer = UIPanGestureRecognizer(target: self, action: "groupingBeingPanned:")
      self.view?.addGestureRecognizer(movingPanRecognizer)
    } else {
      self.view?.gestureRecognizers?.removeAll()
      addGestureRecognizers()
    }
  }
  
  func newLeafInitiatedOnGrouping(sender: UITapGestureRecognizer) {
    self.treeDelegate?.addNewLeafToGrouping(self, sender: sender)
  }
  
  func groupingMoveInitiated(sender: UIGestureRecognizer) {
    treeDelegate?.sharedStore().treeStore.currentLeaves?.forEach({ (leaf) -> () in
      leaf.deselectLeaf()
    })
    treeDelegate?.sharedStore().treeStore.currentGroupings?.forEach({ (grouping) -> () in
      if grouping.groupingId != self.groupingId {
        grouping.deselectGrouping()
      }
    })
    self.drawGroupingSelected()
    self.movingEnabled = true
//    let state = sender.state
//    if state == UIGestureRecognizerState.Changed {
//      groupingBeingPanned(sender)
//    } else if state == UIGestureRecognizerState.Ended {
//      togglePanActivation(false)
//      //      movingEnabled = false
//      //      deselectLeaf()
//    } else {
//      self.drawGroupingSelected()
//      self.movingEnabled = true
//      togglePanActivation(true)
//    }
  }
  
  func groupingBeingPlaced() {
    if movingEnabled {
      movingEnabled = false
      deselectGrouping()
    }
  }
  
  func deleteButtonPressed() {
    self.changeStatus = .Removed
    togglePanActivation(false)
    self.treeDelegate?.removeObjectFromView(self)
    treeDelegate?.sharedStore().removeConnectionsForObject(self)
  }
  
  //need a new way to place a leaf ( like drag from a blob on the upper left or something
  // then you need to make the move gesture a double click, and the connection draw a long press.
  // that way you can keep scrolling as moving around the tree

  
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