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
  var previousConnectionLayer: CAShapeLayer?
  
  
  override func viewDidLoad() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchTreeData", name: "leavesPopulated", object: nil)
      super.viewDidLoad()

    // Do any additional setup after loading the view.
    configureScrollView()
    fetchTreeData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
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
  
  func addLeafToScrollView(leaf: Leaf) {
    if let view = leaf.view {
      self.scrollView.addSubview(view)
      checkForOverlaps(leaf)
      PeatContentStore.sharedStore.addLeafToStore(leaf)
    }
  }
  
  func leafBeingMoved(leaf: Leaf, sender: UIGestureRecognizer) {
    if let view = leaf.view {
      self.scrollView.bringSubviewToFront(view)
      let center = sender.locationInView(self.scrollView)
      leaf.view?.center = center
      //deal with connections
      if let connections = PeatContentStore.sharedStore.treeStore.currentConnections, leaves = PeatContentStore.sharedStore.treeStore.currentLeaves {
        for connection in connections {
          for maybeConnected in leaves {
            if connection.toId == maybeConnected.leafId || connection.fromId == maybeConnected.leafId {
              if let fromLeafId = connection.fromId, fromLeaf = PeatContentStore.sharedStore.leafWithId(fromLeafId) {
                connectionsBeingDrawn(fromLeaf, sender: sender, previousConnection: connection)
              }
              //probably just redraw the connection starting with a new bezier path on the previous leaf
            }
          }
        }
      }
      self.profileDelegate?.changesMade(leaf)
    }
    //allow the leaf to move with the gesture until the gesture is finished, then place the leaf and remove the shadow
  }
  
  func connectionsBeingDrawn(fromLeaf: Leaf, sender: UIGestureRecognizer, previousConnection: LeafConnection?) {
    if let view = fromLeaf.view {
      let finger = sender.locationInView(self.scrollView)
      let path = UIBezierPath()
      path.moveToPoint(view.center)
      path.addLineToPoint(finger)
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      //TODO: check completionStatus when line set?
      shapeLayer.strokeColor = UIColor.grayColor().CGColor
      shapeLayer.zPosition = -1
      
      var connected = false
      var toLeaf: Leaf?
      //gesture ending, check if should place line
      if sender.state == UIGestureRecognizerState.Ended {
        for leaf in PeatContentStore.sharedStore.leaves {
          if leaf != fromLeaf {
            if let leafView = leaf.view {
              if CGRectContainsPoint(leafView.frame, finger) {
                connected = true
                toLeaf = leaf
              }
            }
          }
        }
        if connected {
          //connected, place
          self.drawConnectionLayer(shapeLayer, from: fromLeaf, to: toLeaf, previousConnection: nil)
        } else {
          //not connected, remove
          self.previousConnectionLayer?.removeFromSuperlayer()
        }
        //gesture not ending, just keep drawing
      } else {
        self.drawConnectionLayer(shapeLayer, from: nil, to: nil, previousConnection: previousConnection)
      }
    }
  }
  
  func drawConnectionLayer(connection: CAShapeLayer, from: Leaf?, to: Leaf?, previousConnection: LeafConnection?) {
    //when picking up a leaf that already has a conenction
    if let lastPlacedConnection = previousConnection?.connectionLayer {
      self.previousConnectionLayer = lastPlacedConnection
      previousConnection?.connectionLayer = nil
    }
    //just normal movement
    if let previous = self.previousConnectionLayer {
      previous.removeFromSuperlayer()
    }
    if let from = from, to = to {
      let newConnection = LeafConnection.newConnection(connection, from: from, to: to)
      PeatContentStore.sharedStore.addConnection(newConnection)
      scrollView.layer.addSublayer(connection)
      self.previousConnectionLayer = nil
    } else {
      scrollView.layer.addSublayer(connection)
      self.previousConnectionLayer = connection
    }
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
  
  func dealWithGroupings(higherLeaf: Leaf, lowerLeaf: Leaf) {
  //[{name: String, color: String, zIndex: Number}]
    if let existingGrouping = lowerLeaf.grouping {
      //add the leaf to the existing grouping
    } else {
      //create new grouping and put both leaves in it
      //prompt user for a name in a popover text field
      let groupingName = "Rails"
      let newGrouping = LeafGrouping.newGrouping(groupingName)
      higherLeaf.grouping = newGrouping
      lowerLeaf.grouping = newGrouping
      
      
    }
  }
  
  func displayLeaves() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      for leaf in PeatContentStore.sharedStore.leaves {
        leaf.treeDelegate = self
        leaf.generateBounds()
        leaf.drawConnections()
      }
    })
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
