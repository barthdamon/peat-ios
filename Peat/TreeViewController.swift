//
//  TreeViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/25/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class TreeViewController: UIViewController, TreeDelegate {
  
  // Dynamic Data
//  var leaves: [Leaf] = Array()
  var selectedLeaf: Leaf?
  var changesMade: Bool = false
  var viewing: User?
  
  var hoverTimer: NSTimer?
  
  var profileDelegate: ProfileViewController?
  var currentActivity: String = "Snowboarding"

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var saveButton: UIButton!
  
  //Drawing
  var previousConnectionDrawing: CAShapeLayer?
  
  override func viewDidLoad() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchTreeData", name: "leavesPopulated", object: nil)
      super.viewDidLoad()

    // Do any additional setup after loading the view.
    configureScrollView()
    fetchTreeData()
  }
  
  func getCurrentActivity() -> String {
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
    scrollView.contentSize.height = 1000
    scrollView.contentSize.width = 1000
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
      self.profileDelegate?.changesMade(leaf, grouping: nil)
      
        //Check for grouping hover, with a timer, if it
        //allow the leaf to move with the gesture until the gesture is finished, then place the leaf and remove the shadow
        var hovering = false
        var hoveredGrouping: LeafGrouping?
        var hoveredLeaf: Leaf?
      
        //check if hovering over existing grouping
        if let groupings = PeatContentStore.sharedStore.treeStore.currentGroupings {
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
      if let leaves = PeatContentStore.sharedStore.treeStore.currentLeaves {
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
          if let grouping = hoveredGrouping {
            hoverTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "addLeafToGrouping:", userInfo: ["leaf" : leaf, "grouping" : grouping], repeats: false)
          } else if let lowerLeaf = hoveredLeaf {
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
  func findExistingConnectionsForMoving(leaf: Leaf) -> Array<(leaf: Leaf, connection: LeafConnection)>? {
    if let connections = PeatContentStore.sharedStore.treeStore.currentConnections, leaves = PeatContentStore.sharedStore.treeStore.currentLeaves {
      var anchorLeaves: Array<(leaf: Leaf, connection: LeafConnection)> = Array()
      for connection in connections {
        //          var toLeaf: Leaf?
        for maybeConnected in leaves {
          if connection.toId == maybeConnected.leafId && connection.fromId == leaf.leafId || connection.fromId == maybeConnected.leafId && connection.toId == leaf.leafId {
            anchorLeaves.append(leaf: maybeConnected, connection: connection)
          }
        }
      }
      if anchorLeaves.count > 0 {
        return anchorLeaves
      }
    }
    return nil
  }
  
  func findExistingConnectionsForDrawn(leaf: Leaf) -> (leaf: Leaf, connection: LeafConnection)? {
    var anchorLeaf: (leaf: Leaf, connection: LeafConnection)?
    if let connections = PeatContentStore.sharedStore.treeStore.currentConnections, leaves = PeatContentStore.sharedStore.treeStore.currentLeaves {
      for connection in connections {
        //          var toLeaf: Leaf?
        if connection.fromId == leaf.leafId && connection.toId == nil {
          anchorLeaf = (leaf: leaf, connection: connection)
        }
      }
    }
    return anchorLeaf
  }
  
  func connectionsBeingDrawn(fromLeaf: Leaf?, fromGrouping: LeafGrouping?, sender: UIGestureRecognizer) {
    if let fromLeaf = fromLeaf {
      if let anchor = findExistingConnectionsForDrawn(fromLeaf) {
        //should only be one in this case if it gets found....
        updateConnection(anchor, sender: sender)
      } else {
        drawConnection(fromLeaf, sender: sender, existingConnection: nil)
      }
    } else if let fromGrouping = fromGrouping {
      
    }
  }
  
  func updateConnection(anchor: (leaf: Leaf, connection: LeafConnection), sender: UIGestureRecognizer) {
    if let parentView = anchor.leaf.parentView() {
      let finger = sender.locationInView(parentView)
      if sender.state == UIGestureRecognizerState.Ended {
        var connected = false
        for storedLeaf in PeatContentStore.sharedStore.leaves {
          if storedLeaf != anchor.leaf {
            if let leafView = storedLeaf.view {
              if CGRectContainsPoint(leafView.frame, finger) {
                anchor.connection.toId = storedLeaf.leafId
                connected = true
              }
            }
          }
        }
        if !connected {
          anchor.connection.connectionLayer?.removeFromSuperlayer()
        }
      } else {
        anchor.connection.connectionLayer?.removeFromSuperlayer()
        drawConnection(anchor.leaf, sender: sender, existingConnection: anchor.connection)
      }
    }
  }
  
  func drawConnection(fromLeaf: Leaf, sender: UIGestureRecognizer, existingConnection: LeafConnection?) {
    if let view = fromLeaf.view, parentView = fromLeaf.parentView(){
      //see if there is an eistingConnection first
      let finger = sender.locationInView(parentView)
      let path = UIBezierPath()
      path.moveToPoint(view.center)
      path.addLineToPoint(finger)
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      //TODO: check completionStatus when line set?
      shapeLayer.strokeColor = UIColor.grayColor().CGColor
      shapeLayer.zPosition = -1
      if let existing = existingConnection {
        existing.connectionLayer = shapeLayer
      } else {
        PeatContentStore.sharedStore.newConnection(shapeLayer, from: fromLeaf, to: nil)
      }
      scrollView.layer.addSublayer(shapeLayer)
    }
  }
  
  
  //MARK: Groupings
  
  
//  func dealWithGroupings(higherLeaf: Leaf, lowerLeaf: Leaf) {
//  //[{name: String, color: String, zIndex: Number}]
//    if let existingGrouping = lowerLeaf.grouping {
//      //add the leaf to the existing grouping
//      //need a didset that adds the leaf to the grouping view if the grouping view exists perhaps??
//      higherLeaf.grouping = lowerLeaf.grouping
//    } else {
//      //create new grouping and put both leaves in it
//      //prompt user for a name in a popover text field
////        let newGrouping = LeafGrouping.newGrouping(center)
////        higherLeaf.grouping = newGrouping
////        lowerLeaf.grouping = newGrouping
//        drawGrouping(lowerLeaf, higherLeaf: higherLeaf)
//    }
//  }
  
  func groupingBeingMoved(grouping: LeafGrouping, sender: UIGestureRecognizer) {
    if let view = grouping.view {
      self.scrollView.bringSubviewToFront(view)
      let center = sender.locationInView(self.scrollView)
      grouping.view?.center = center
      //deal with connections
      self.profileDelegate?.changesMade(nil, grouping: grouping)
    }
//    if let existingAnchors = findExistingConnectionsForMoving(leaf) {
//      for anchor in existingAnchors {
//        updateConnection(anchor, sender: sender)
//      }
//    }
  }
  
  func addLeafToGrouping(timer: NSTimer) {
    if let info = timer.userInfo as? Dictionary<String, AnyObject>, leaf = info["leaf"] as? Leaf, grouping = info["grouping"] as? LeafGrouping, leafView = leaf.view, groupingView = grouping.view {
      //add leaf to
      leafView.removeFromSuperview()
      leafView.center.x -= groupingView.center.x
      leafView.center.y -= groupingView.center.y
      groupingView.addSubview(leafView)
    }
  }
  
  func newGrouping(timer: NSTimer) {
    if let info = timer.userInfo as? Dictionary<String, AnyObject>, leaf = info["leaf"] as? Leaf, lowerLeaf = info["lowerLeaf"] as? Leaf, leafView = leaf.view, lowerView = lowerLeaf.view, center = lowerLeaf.center {
      let newGrouping = LeafGrouping.newGrouping(center, delegate: self)
      newGrouping.drawGrouping(lowerLeaf, highlightedLeaf: leaf)
    }
  }
  
  //Mark General Drawing:
  func addGroupingToScrollView(grouping: LeafGrouping, lowerLeaf: Leaf, higherLeaf: Leaf) {
    if let view = grouping.view {
      self.scrollView.addSubview(view)
      PeatContentStore.sharedStore.addGroupingToStore(grouping)
      if let lowerView = lowerLeaf.view, highlightedView = higherLeaf.view {
//        highlightedView.removeFromSuperview()
//        lowerView.removeFromSuperview()
        view.addSubview(lowerView)
        view.addSubview(highlightedView)
        lowerView.center.x = Leaf.standardWidth
        lowerView.center.y = Leaf.standardHeight / 2
        highlightedView.center.x = Leaf.standardWidth
        highlightedView.center.y = Leaf.standardHeight * 2
        higherLeaf.deselectLeaf()
      }
    }
  }
  
  func addLeafToScrollView(leaf: Leaf) {
    if let view = leaf.view {
      self.scrollView.addSubview(view)
      checkForOverlaps(leaf)
      PeatContentStore.sharedStore.addLeafToStore(leaf)
    }
  }
  
  func displayLeaves() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      for leaf in PeatContentStore.sharedStore.leaves {
        leaf.treeDelegate = self
        leaf.generateBounds()
//        leaf.drawConnections()
      }
    })
  }

  func checkForOverlaps(intruder: Leaf) {
    for leaf in PeatContentStore.sharedStore.leaves {
      if leaf != intruder {
        if let intruderView = intruder.view, leafView = leaf.view {
          if CGRectIntersectsRect(leafView.frame, intruderView.frame) {
            //TODO: offset these more intelligently. still do, but make them a group
            intruderView.center.x += Leaf.standardWidth
            intruderView.center.y += Leaf.standardHeight
            let newOffsetX = intruderView.center.x - self.scrollView.frame.width / 2
            let newOffsetY = intruderView.center.y - self.scrollView.frame.height / 2
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
    //In the future get the data for the selected user and the selected activity
    PeatContentStore.sharedStore.getTreeData(self, viewing: viewing){ (success) -> () in
      if success {
        self.displayLeaves()
      } else {
        //show error
      }
    }
  }
  
  func drillIntoLeaf(leaf: Leaf) {
    selectedLeaf = leaf
    self.profileDelegate?.drillIntoLeaf(leaf)
  }
  
  func newLeafInitiated(sender: UILongPressGestureRecognizer) {
    print("Sender: \(sender)")
    let center: CGPoint = sender.locationInView(self.scrollView)
    print("SENDER: \(center)")
    let newLeaf = Leaf.initFromTree(center, delegate: self, scrollView: self.scrollView)
    newLeaf.generateBounds()
    self.profileDelegate?.changesMade(newLeaf, grouping: nil)
  }
  
  func removeLeafFromView(leaf: Leaf) {
    if let view = leaf.view {
      view.removeFromSuperview()
      self.profileDelegate?.changesMade(leaf, grouping: nil)
    }
  }
}
