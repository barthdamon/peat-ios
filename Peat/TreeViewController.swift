//
//  TreeViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/25/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

protocol TreeDelegate {
  func fetchTreeData()
  func viewForTree() -> UIView?
  func getCurrentActivity() -> Activity?
  func addLeafToScrollView(leaf: Leaf)
  func addLeafToGrouping(leaf: Leaf, grouping: LeafGrouping)
  func drillIntoLeaf(leaf: Leaf)
  func leafBeingMoved(leaf: Leaf, sender: UIGestureRecognizer)
  func checkForOverlaps(intruder: Leaf)
  func removeObjectFromView(object: TreeObject)
  func connectionsBeingDrawn(fromLeaf: Leaf?, fromGrouping: LeafGrouping?, sender: UIGestureRecognizer)
  func addGroupingToScrollView(grouping: LeafGrouping)
  func groupingBeingMoved(leaf: LeafGrouping, sender: UIGestureRecognizer)
  func addNewLeafToGrouping(grouping: LeafGrouping, sender: UITapGestureRecognizer)
  func sharedStore() -> PeatContentStore
}

class TreeViewController: UIViewController, TreeDelegate, UIScrollViewDelegate {
  
  // Dynamic Data
//  var leaves: [Leaf] = Array()
  var selectedLeaf: Leaf?
  var changesMade: Bool = false
  var viewing: User?
  var store: PeatContentStore?
  
  var hoverTimer: NSTimer?
  
  var profileDelegate: ProfileViewController?
  var currentActivity: Activity? {
    return store?.treeStore.currentActivity
  }

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var saveButton: UIButton!
  
  var treeView: UIView = UIView()
  
  //Drawing
  var previousConnectionDrawing: CAShapeLayer?
  
  override func viewDidLoad() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchTreeData", name: "leavesPopulated", object: nil)
      super.viewDidLoad()

    // Do any additional setup after loading the view.
    
    configureScrollView()
    fetchTreeData()
  }
  
  func sharedStore() -> PeatContentStore {
    if let store = store {
      return store
    } else {
      //should never have to do this...
      return PeatContentStore()
    }
  }
  
  func toggleActive(active: Bool) {
    self.treeView.userInteractionEnabled = active
    self.scrollView.userInteractionEnabled = active
  }
  
  func getCurrentActivity() -> Activity? {
    return currentActivity
  }
  
  func configureScrollView() {
    if let _ = viewing {
      //Do whatever for when you are viewing anothers profile
    } else {
      let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "newLeafInitiated:")
      doubleTapRecognizer.numberOfTouchesRequired = 1
      doubleTapRecognizer.numberOfTapsRequired = 2
      scrollView.addGestureRecognizer(doubleTapRecognizer)
    }
//    var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
//    doubleTapRecognizer.numberOfTapsRequired = 2
//    doubleTapRecognizer.numberOfTouchesRequired = 1
//    scrollView.addGestureRecognizer(doubleTapRecognizer)
    scrollView.minimumZoomScale = 0.5
    scrollView.maximumZoomScale = 6
    scrollView.contentSize.height = 1000
    scrollView.contentSize.width = 1000
    scrollView.delegate = self
    
    //note: 65 cause of the stupid navbar
    self.treeView = UIView(frame: CGRectMake(0,-65,1000,2000))
    treeView.backgroundColor = UIColor.lightGrayColor()
    self.scrollView.addSubview(self.treeView)
  }
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.treeView
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    //do something to expand the view if the user is getting to the edge, then unexpand when the content is shrinking and none of the views are out there
  }
  
  func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
    let newScale = scrollView.zoomScale
    self.treeView.contentScaleFactor = newScale
  }
  
  //MARK: Movement
  func leafBeingMoved(leaf: Leaf, sender: UIGestureRecognizer) {
    if let view = leaf.view {
      var finger: CGPoint = CGPoint()
      if let parentView = leaf.parentView() {
        parentView.bringSubviewToFront(view)
        finger = sender.locationInView(parentView)
      }
      leaf.view?.center = finger
      leaf.changed(.Updated)
      self.profileDelegate?.changesMade()
      
        //Check for grouping hover, with a timer, if it
        //allow the leaf to move with the gesture until the gesture is finished, then place the leaf and remove the shadow
        var hovering = false
        var hoveredGrouping: LeafGrouping?
        var hoveredLeaf: Leaf?
      
        //check if hovering over existing grouping
        if let groupings = sharedStore().treeStore.currentGroupings {
          for grouping in groupings {
            if let groupingView = grouping.view {
              if CGRectContainsPoint(groupingView.frame, finger) {
                hovering = true
                hoveredGrouping = grouping
              }
            }
          }
        }

      //Check if hovering ove existing leaf for new grouping being made
      if let leaves = sharedStore().treeStore.currentLeaves {
        for lowerLeaf in leaves {
          if let lowerView = lowerLeaf.view where lowerLeaf != leaf {
            if CGRectContainsPoint(lowerView.frame, finger) {
              hovering = true
              hoveredLeaf = lowerLeaf
            }
          }
        }
      }
        
      if hovering {
        if let _ = hoverTimer {
          print("Hovering")
        } else {
          if let grouping = hoveredGrouping where leaf.grouping == nil {
            hoverTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "moveLeafToGrouping:", userInfo: ["leaf" : leaf, "grouping" : grouping], repeats: false)
          } else if let lowerLeaf = hoveredLeaf where leaf.grouping == nil {
            hoverTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "newGrouping:", userInfo: ["leaf" : leaf, "lowerLeaf" : lowerLeaf], repeats: false)
          }
        }
      } else {
        hoverTimer = nil
      }
      
      //Update connections
      if let existingAnchors = findExistingConnectionsForMoving(leaf) {
        for anchor in existingAnchors {
          updateConnection(anchor, sender: sender)
        }
      }
      
    }
  }
  
  
  //MARK: CONNECTIONS
  //find all connections for moving object to update them when they need to be
  func findExistingConnectionsForMoving(object: TreeObject) -> Array<(object: TreeObject, connection: LeafConnection)>? {
    var anchorLeaves: Array<(object: TreeObject, connection: LeafConnection)> = Array()
    for connection in sharedStore().connections {
      //          var toLeaf: Leaf?
      for maybeConnected in sharedStore().leaves {
        if (connection.toId == maybeConnected.leafId && connection.fromId == object.objectId()) || (connection.fromId == maybeConnected.leafId && connection.toId == object.objectId()) {
          anchorLeaves.append((object: maybeConnected, connection: connection))
        }
      }
      for maybeConnected in sharedStore().groupings {
        if (connection.toId == maybeConnected.groupingId && connection.fromId == object.objectId()) || (connection.fromId == maybeConnected.groupingId && connection.toId == object.objectId()) {
          anchorLeaves.append((object: maybeConnected, connection: connection))
        }
      }
    }
    return anchorLeaves
  }
  
  //This exists becasue connections are created when you start drawing, the to and from are added later
  func findExistingConnectionsForObject(object: TreeObject) -> (object: TreeObject, connection: LeafConnection)? {
    var anchor: (object: TreeObject, connection: LeafConnection)?
      for connection in sharedStore().connections {
        //          var toLeaf: Leaf?
        if connection.fromId == object.objectId() && connection.toId == nil {
          anchor = (object: object, connection: connection)
        }
      }
    return anchor
  }
  
  func connectionsBeingDrawn(fromLeaf: Leaf?, fromGrouping: LeafGrouping?, sender: UIGestureRecognizer) {
    if let fromLeaf = fromLeaf {
      if let anchor = findExistingConnectionsForObject(fromLeaf) {
        //should only be one in this case if it gets found....
        updateConnection(anchor, sender: sender)
      } else {
        drawConnection(fromLeaf, sender: sender, existingConnection: nil)
      }
    } else if let fromGrouping = fromGrouping {
      if let anchor = findExistingConnectionsForObject(fromGrouping) {
        //should only be one in this case if it gets found....
        updateConnection(anchor, sender: sender)
      } else {
        drawConnection(fromGrouping, sender: sender, existingConnection: nil)
      }
    }
  }
  
  func updateConnection(anchor: (object: TreeObject, connection: LeafConnection), sender: UIGestureRecognizer) {
    if let parentView = anchor.object.parentView() {
      let finger = sender.locationInView(parentView)
      if sender.state == UIGestureRecognizerState.Ended {
        var connected = false
        for storedLeaf in sharedStore().leaves {
          if storedLeaf.leafId != anchor.object.objectId() && !sharedStore().checkForExistingLeaf(anchor.object, to: storedLeaf)  {
            if let leafView = storedLeaf.view {
              if CGRectContainsPoint(leafView.frame, finger) {
                anchor.connection.toId = storedLeaf.leafId
                connected = true
                //only save when connection to other leaf occurs
                anchor.connection.changed(.BrandNew)
                self.profileDelegate?.changesMade()
              }
            }
          }
        }
        for storedGrouping in sharedStore().groupings {
          if storedGrouping.groupingId != anchor.object.objectId() && !sharedStore().checkForExistingLeaf(anchor.object, to: storedGrouping) {
            if let groupingView = storedGrouping.view {
              if CGRectContainsPoint(groupingView.frame, finger) {
                anchor.connection.toId = storedGrouping.groupingId
                connected = true
                //only save when connection to other leaf occurs
                anchor.connection.changed(.BrandNew)
                self.profileDelegate?.changesMade()
              }
            }
          }
        }
        if !connected {
          anchor.connection.connectionLayer?.removeFromSuperlayer()
//          PeatContentStore.sharedStore.removeConnection(anchor.connection)
        }
      } else {
        anchor.connection.connectionLayer?.removeFromSuperlayer()
        drawConnection(anchor.object, sender: sender, existingConnection: anchor.connection)
      }
    }
  }
  
  func drawConnection(fromObject: TreeObject, sender: UIGestureRecognizer, existingConnection: LeafConnection?) {
    if let view = fromObject.viewForTree(), parentView = fromObject.parentView(){
      //see if there is an eistingConnection first
      let finger = sender.locationInView(parentView)
      let path = UIBezierPath()
      path.moveToPoint(view.center)
      path.addLineToPoint(finger)
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      //TODO: check completionStatus when line set?
      shapeLayer.strokeColor = UIColor.grayColor().CGColor
      shapeLayer.zPosition = -200

      if let existing = existingConnection {
        existing.connectionLayer = shapeLayer
      } else {
        sharedStore().newConnection(shapeLayer, from: fromObject, to: nil, delegate: self)
      }
      parentView.layer.addSublayer(shapeLayer)
    }
  }
  
  func drawFreshConnection(connection: LeafConnection) {
    if let fromObject = connection.fromObject, toObject = connection.toObject, fromView = fromObject.viewForTree(), toView = toObject.viewForTree(), parentView = fromObject.parentView() where connection.changeStatus != .Removed {
      let path = UIBezierPath()
      path.moveToPoint(fromView.center)
      path.addLineToPoint(toView.center)
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      //TODO: check completionStatus when line set?
      shapeLayer.strokeColor = UIColor.grayColor().CGColor
      shapeLayer.zPosition = -200
      parentView.layer.addSublayer(shapeLayer)
      connection.connectionLayer = shapeLayer
    }
  }
  
  
  //MARK: Groupings
  
  func groupingBeingMoved(grouping: LeafGrouping, sender: UIGestureRecognizer) {
    if let view = grouping.view {
      self.treeView.bringSubviewToFront(view)
      let center = sender.locationInView(self.treeView)
      grouping.view?.center = center
      //deal with connections
      grouping.changed(.Updated)
      self.profileDelegate?.changesMade()
    }
    if let existingAnchors = findExistingConnectionsForMoving(grouping) {
      for anchor in existingAnchors {
        updateConnection(anchor, sender: sender)
      }
    }
  }
  
  func addNewLeafToGrouping(grouping: LeafGrouping, sender: UITapGestureRecognizer) {
    if let view = grouping.view {
      let center: CGPoint = sender.locationInView(view)
      let newLeaf = Leaf.initFromTree(center, delegate: self)
      newLeaf.grouping = grouping
      newLeaf.generateBounds()
      newLeaf.changed(.BrandNew)
      self.profileDelegate?.changesMade()
    }
  }
  
  func moveLeafToGrouping(timer: NSTimer) {
    if let info = timer.userInfo as? Dictionary<String, AnyObject>, leaf = info["leaf"] as? Leaf, grouping = info["grouping"] as? LeafGrouping, leafView = leaf.view, groupingView = grouping.view {
      //add leaf to
      groupingView.addSubview(leafView)
      leafView.center.x = Leaf.standardWidth
      leafView.center.y = Leaf.standardHeight * 2
      leaf.grouping = grouping
    }
  }
  
  func newGrouping(timer: NSTimer) {
    if let info = timer.userInfo as? Dictionary<String, AnyObject>, leaf = info["leaf"] as? Leaf, lowerLeaf = info["lowerLeaf"] as? Leaf, center = lowerLeaf.center {
      let newGrouping = LeafGrouping.newGrouping(center, delegate: self)
      newGrouping.drawGrouping()
      addLeavesToGrouping(newGrouping, leaves: [lowerLeaf, leaf])
      leaf.grouping = newGrouping
      lowerLeaf.grouping = newGrouping
      leaf.deselectLeaf()
      self.profileDelegate?.changesMade()
      leaf.changed(.Updated)
      lowerLeaf.changed(.Updated)
      newGrouping.changed(.BrandNew)
    }
  }
  
  func removeGroupingFromView(grouping: LeafGrouping) {
    if let view = grouping.view {
      view.removeFromSuperview()
      grouping.changed(.Removed)
      //move the leaves out of the grouping view
      self.profileDelegate?.changesMade()
    }
  }
  
  func addLeavesToGrouping(grouping: LeafGrouping, leaves: Array<Leaf>) {
    if let groupingView = grouping.view {
      for leaf in leaves {
        if let view = leaf.view {
          groupingView.addSubview(view)
          view.center.x = groupingView.center.x - groupingView.frame.minX
          view.center.y = groupingView.center.y - groupingView.frame.minY
        }
      }
    }
  }
  
  //Mark General Drawing:
  func addGroupingToScrollView(grouping: LeafGrouping) {
    if let view = grouping.view {
      view.layer.zPosition = -10
      self.treeView.addSubview(view)
      sharedStore().addGroupingToStore(grouping)
    }
  }
  
  func addLeafToScrollView(leaf: Leaf) {
    if let view = leaf.view {
      self.treeView.addSubview(view)
      checkForOverlaps(leaf)
    }
  }
  
  func addLeafToGrouping(leaf: Leaf, grouping: LeafGrouping) {
    if let leafView = leaf.view, groupingView = grouping.view {
      groupingView.addSubview(leafView)
    }
  }
  
  func displayLeaves() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      //leaves will have the grouping, just draw the grouping
      for grouping in self.sharedStore().groupings {
        grouping.drawGrouping()
      }
      
      for leaf in self.sharedStore().leaves {
        //if leaf has a groupingId, add leaf to the grouping, not the treeView
        leaf.treeDelegate = self
        leaf.findGrouping()
        leaf.generateBounds()
      }
      
      for connection in self.sharedStore().connections {
        self.sharedStore().attachObjectsToConnection(connection)
        self.drawFreshConnection(connection)
      }
      
    })
  }

  func checkForOverlaps(intruder: Leaf) {
    for leaf in sharedStore().leaves {
      if leaf != intruder {
        if let intruderView = intruder.view, leafView = leaf.view {
          if CGRectIntersectsRect(leafView.frame, intruderView.frame) {
            //TODO: offset these more intelligently. still do, but make them a group
            intruderView.center.x += Leaf.standardWidth
            intruderView.center.y += Leaf.standardHeight
            let newOffsetX = intruderView.center.x - self.treeView.frame.width / 2
            let newOffsetY = intruderView.center.y - self.treeView.frame.height / 2
            //need to check if intruder view is in a group already first
            self.scrollView.setContentOffset(CGPointMake(newOffsetX, newOffsetY), animated: true)
            checkForOverlaps(intruder)
          }
        }
      }
    }
  }

  func fetchTreeData() {
    //right now it redraws every time... no harm in that
    for view in self.treeView.subviews {
      view.removeFromSuperview()
    }
    //In the future get the data for the selected user and the selected activity
    if let activity = self.currentActivity {
      sharedStore().getTreeData(self, viewing: viewing, activity: activity){ (success) -> () in
        if success {
          self.displayLeaves()
        } else {
          //show error
        }
      }
    }
  }
  
  func drillIntoLeaf(leaf: Leaf) {
    selectedLeaf = leaf
    self.profileDelegate?.drillIntoLeaf(leaf)
  }
  
  func newLeafInitiated(sender: UILongPressGestureRecognizer) {
    print("Sender: \(sender)")
    let center: CGPoint = sender.locationInView(self.treeView)
    print("SENDER: \(center)")
    let newLeaf = Leaf.initFromTree(center, delegate: self)
    newLeaf.generateBounds()
    newLeaf.changed(.BrandNew)
    self.profileDelegate?.changesMade()
  }
  
  func removeObjectFromView(object: TreeObject) {
    if let view = object.viewForTree() {
      view.removeFromSuperview()
      object.changed(.Removed)
      if object is LeafGrouping {
        emptyGroupingContainer(object as! LeafGrouping)
      }
      self.profileDelegate?.changesMade()
    }
  }
  
  func emptyGroupingContainer(grouping: LeafGrouping) {
    for leaf in sharedStore().leaves {
      if leaf.groupingId == grouping.groupingId {
        leaf.groupingId = nil
        leaf.grouping = nil
        //redraw connections
        leaf.changed(.Updated)
        self.addLeafToScrollView(leaf)
        if let groupingView = grouping.view {
          leaf.view?.center.x += groupingView.center.x
          leaf.view?.center.y += groupingView.center.y
        }
      }
    }
    for connection in sharedStore().connections {
      if connection.fromId == grouping.groupingId || connection.toId == grouping.groupingId {
        connection.changed(.Removed)
      }
      connection.connectionLayer?.removeFromSuperlayer()
      drawFreshConnection(connection)
    }
  }
  
//  func setCurrentActivityTree(activity: Activity) {
//    self.currentActivity = activity
//    fetchTreeData()
//  }
  
  func viewForTree() -> UIView? {
    return self.treeView
  }
  
}
