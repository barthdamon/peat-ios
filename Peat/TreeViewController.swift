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
      self.scrollView.bringSubviewToFront(view)
      let center = sender.locationInView(self.scrollView)
      leaf.view?.center = center
      //deal with connections
      self.profileDelegate?.changesMade(leaf)
    }
    if let existingAnchors = findExistingConnectionsForMoving(leaf) {
      for anchor in existingAnchors {
        updateConnection(anchor, sender: sender)
      }
    }
    //allow the leaf to move with the gesture until the gesture is finished, then place the leaf and remove the shadow
  }
  
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
        if connection.fromId == leaf.leafId || connection.toId == nil {
          anchorLeaf = (leaf: leaf, connection: connection)
        }
      }
    }
    return anchorLeaf
  }
  
  func connectionsBeingDrawn(fromLeaf: Leaf, sender: UIGestureRecognizer) {
    if let anchor = findExistingConnectionsForDrawn(fromLeaf) {
      //should only be one in this case if it gets found....
      updateConnection(anchor, sender: sender)
    } else {
      drawConnection(fromLeaf, sender: sender)
    }
  }
  
  func updateConnection(anchor: (leaf: Leaf, connection: LeafConnection), sender: UIGestureRecognizer) {
    let finger = sender.locationInView(self.scrollView)
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
      let path = UIBezierPath()
      path.moveToPoint(view.center)
      path.addLineToPoint(finger)
      anchor.connection.connectionLayer?.path = path.CGPath
//      let path = UIBezierPath()
//      anchor.connection.connectionLayer?.removeFromSuperlayer()
//      let finger = sender.locationInView(self.scrollView)
//      path.moveToPoint(view.center)
//      path.addLineToPoint(finger)
//      let shapeLayer = CAShapeLayer()
//      shapeLayer.path = path.CGPath
//      //TODO: check completionStatus when line set?
//      shapeLayer.strokeColor = UIColor.grayColor().CGColor
//      anchor.connection.connectionLayer = shapeLayer
//      scrollView.layer.addSublayer(shapeLayer)
    }
  }
  
  func drawConnection(fromLeaf: Leaf, sender: UIGestureRecognizer) {
    if let view = fromLeaf.view {
      //see if there is an eistingConnection first
      let finger = sender.locationInView(self.scrollView)
      let path = UIBezierPath()
      path.moveToPoint(view.center)
      path.addLineToPoint(finger)
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      //TODO: check completionStatus when line set?
      shapeLayer.strokeColor = UIColor.grayColor().CGColor
      shapeLayer.zPosition = -1
      PeatContentStore.sharedStore.newConnection(shapeLayer, from: fromLeaf, to: nil)
      scrollView.layer.addSublayer(shapeLayer)
    }
  }
  
  
  //MARK: Groupings
  func dealWithGroupings(higherLeaf: Leaf, lowerLeaf: Leaf) {
  //[{name: String, color: String, zIndex: Number}]
    if let existingGrouping = lowerLeaf.grouping {
      //add the leaf to the existing grouping
      higherLeaf.grouping = lowerLeaf.grouping
    } else {
      //create new grouping and put both leaves in it
      //prompt user for a name in a popover text field
      let groupingName = "Rails"
      let newGrouping = LeafGrouping.newGrouping(groupingName)
      higherLeaf.grouping = newGrouping
      lowerLeaf.grouping = newGrouping
    }
  }
  
  
  
  
  //Mark General Drawing:
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
            dealWithGroupings(leaf, lowerLeaf: intruder)
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
    let newLeaf = Leaf.initFromTree(center, delegate: self)
    newLeaf.generateBounds()
    self.profileDelegate?.changesMade(newLeaf)
  }
  
  func removeLeafFromView(leaf: Leaf) {
    if let view = leaf.view {
      view.removeFromSuperview()
      self.profileDelegate?.changesMade(leaf)
    }
  }
}
