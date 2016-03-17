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
  func connectionsBeingDrawn(fromObject: TreeObject, sender: UIGestureRecognizer)
  func addGroupingToScrollView(grouping: LeafGrouping)
  func groupingBeingMoved(leaf: LeafGrouping, sender: UIGestureRecognizer)
  func addNewLeafToGrouping(grouping: LeafGrouping, sender: UITapGestureRecognizer)
  func sharedStore() -> PeatContentStore
  func checkForNewCompletions()
  func changesMade()
  func isHidingText() -> Bool
}

class TreeViewController: UIViewController, TreeDelegate, UIScrollViewDelegate {
  
  // Dynamic Data
//  var leaves: [Leaf] = Array()
  var selectedLeaf: Leaf?
  var viewing: User?
  var store: PeatContentStore?
  var newLeaf: Leaf?
  var hidingText: Bool = false
  var animating: Bool = false
  
  var hoverTimer: NSTimer?
  var initiationButton: UIImageView?
  var widthIncreaseButton: UIImageView?
  var heightIncreaseButton: UIImageView?
  
  var profileDelegate: ProfileViewController?
  var currentActivity: Activity? {
    return store?.treeStore.currentActivity
  }
  
  var minimumSizeX: CGFloat = 0 { didSet { contentSizeX = minimumSizeX } }
  var contentSizeX: CGFloat = 0 {
    didSet {
      self.scrollView.contentSize.width = contentSizeX
      self.treeView.frame.size.width = contentSizeX
    }
  }
  
  var minimumSizeY: CGFloat = 0 { didSet { contentSizeY = minimumSizeY } }
  var contentSizeY: CGFloat = 0 {
    didSet {
      self.scrollView.contentSize.height = contentSizeY
      self.treeView.frame.size.height = contentSizeY
    }
  }
  
  // Scroll/Tree view content sizes
  var viewWidthSegment: CGFloat = 0.0
  var viewHeightSegment: CGFloat = 0.0
  

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var saveButton: UIButton!
  
  var treeView: UIView = UIView()
  
  var currentXOffset: CGFloat = 0
  var currentYOffset: CGFloat = 0
  
  //Drawing
  var previousConnectionDrawing: CAShapeLayer?
  
  override func viewDidLoad() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchTreeData", name: "leavesPopulated", object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearView", name: "userLoggedOut", object: nil)

      super.viewDidLoad()

    // Do any additional setup after loading the view.
    
//    configureScrollView()
//    fetchTreeData()
  }
  
  func changesMade() {
    self.profileDelegate?.changesMade()
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
    self.scrollView?.userInteractionEnabled = active
  }
  
  func getCurrentActivity() -> Activity? {
    return currentActivity
  }
  
  func isHidingText() -> Bool {
    return hidingText
  }
  
  func clearView() {
    if let sublayers = self.treeView.layer.sublayers {
      for layer in sublayers {
        layer.removeFromSuperlayer()
      }
    }
  }
  
  func configureScrollView() {
    if let _ = viewing {
      //Do whatever for when you are viewing anothers profile
    } else {
      //TODO: make this actually highlight the views
      let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "newLeafInitiated:")
      doubleTapRecognizer.numberOfTouchesRequired = 1
      doubleTapRecognizer.numberOfTapsRequired = 2
//      scrollView.addGestureRecognizer(doubleTapRecognizer)
      
      configureLeafInitiationView()
      drawSizeIncreasers()
    }
//    var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
//    doubleTapRecognizer.numberOfTapsRequired = 2
//    doubleTapRecognizer.numberOfTouchesRequired = 1
//    scrollView.addGestureRecognizer(doubleTapRecognizer)

    viewHeightSegment = self.view.frame.height
    viewWidthSegment = self.view.frame.width
    
    setMinimumSize()
    
    scrollView.minimumZoomScale = 0.3
    scrollView.maximumZoomScale = 1
//    scrollView.contentSize.height = standardHeight
//    scrollView.contentSize.width = standardWidth
    scrollView.delegate = self
    
//    //note: 65 cause of the stupid navbar
    self.treeView = UIView(frame: CGRectMake(0,0,contentSizeX,contentSizeY))
    treeView.backgroundColor = UIColor.darkGrayColor()
    self.scrollView.addSubview(self.treeView)
    //scrollView done, display the leaves!
    self.displayLeaves()
  }
  
  func setMinimumSize() {
    if let store = store {
      let farthestCoordinates = store.getMinimumCoordinates()
      minimumSizeX = farthestCoordinates.x
      minimumSizeY = farthestCoordinates.y
    }
  }
  
  func increaseScrollView(forHeight forHeight: Bool) {
    if forHeight {
      contentSizeY += viewHeightSegment
      // offset the content view down a bit
    } else {
      contentSizeX += viewWidthSegment
      // offset the content view to the side a bit
    }
    toggleWidthIncreaseOption(true)
    toggleHeightIncreaseOption(true)
    //arrow disappears, should only be visible when at the edge of the view
  }
  
  
  func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return self.treeView
  }
  
  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    //do something to expand the view if the user is getting to the edge, then unexpand when the content is shrinking and none of the views are out there
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let offset = scrollView.contentOffset
    
    // need to adjust this by the contentScale
    if offset.x > (contentSizeX - view.frame.width) - Leaf.standardWidth {
      // width wants to increase
      toggleWidthIncreaseOption(false)
    } else {
      toggleWidthIncreaseOption(true)
    }
    
    if offset.y > (contentSizeY - view.frame.height) - Leaf.standardWidth {
      // height wants to increase
      toggleHeightIncreaseOption(false)
    } else {
      toggleHeightIncreaseOption(true)
    }
  }
  
  func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
    let newScale = scrollView.zoomScale
    self.treeView.contentScaleFactor = newScale
    
    
    var width = self.scrollView.contentSize.width * newScale
    var height = self.scrollView.contentSize.height * newScale
    
//    //dont get too small
    if width < minimumSizeX { width = minimumSizeX }
    if height < minimumSizeY { height = minimumSizeY }
    
    self.treeView.frame = CGRectMake(0, 0, width, height)
    
    if newScale < 0.45 {
      toggleTextForZoom(true)
    } else {
      toggleTextForZoom(false)
    }
  }
  
  //MARK: Movement
  
  func toggleTextForZoom(hide: Bool) {
    ///go through all texts, if they arent hidden hide them
    self.hidingText = hide
    if let leaves = store?.treeStore.currentLeaves {
      for leaf in leaves {
        leaf.titleLabel?.hidden = hide
        leaf.uploadsLabel?.hidden = hide
      }
    }
    
    if let groupings = store?.treeStore.currentGroupings {
      for grouping in groupings {
        grouping.titleField?.hidden = hide
      }
    }

  }
  
  //might not need the fancy animations for groupings
  
  func animateLeafGroupingExchange(finger: CGPoint, leaf: Leaf, parentView: UIView, sender: UIGestureRecognizer) {
    if finger.x < -Leaf.standardWidth || finger.y < -Leaf.standardHeight || finger.x > LeafGrouping.standardWidth + Leaf.standardWidth || finger.y > LeafGrouping.standardHeight + Leaf.standardHeight {
      animating = true
      // else if it is far enough out ( that way it has some space to travel and there is a delay
      // it is trying to escape.....
      if let groupingView = leaf.grouping?.view {
        //            leaf.view?.removeFromSuperview()
        leaf.grouping = nil
        leaf.groupingId = nil
        //            leaf.view?.layer.zPosition = 500
        leaf.changed(.Updated)
        self.profileDelegate?.changesMade()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          leaf.view?.transform = CGAffineTransformMakeScale(Leaf.standardExpand + 0.2, Leaf.standardExpand + 0.2)
          }, completion: { (complete) -> Void in
            UIView.animateWithDuration(1, animations: { () -> Void in
              let location = sender.locationInView(groupingView)
              groupingView.clipsToBounds = false
              leaf.view?.center = location
              leaf.view?.transform = CGAffineTransformMakeScale(Leaf.standardExpand, Leaf.standardExpand)
              }, completion: { (complete) -> Void in
                let location = sender.locationInView(self.treeView)
                leaf.view?.center = location
                self.treeView.addSubview(leaf.view!)
                leaf.moveStartPoint = location
                self.animating = false
            })
        })
      }
    }
  }
  
  
  func leafBeingMoved(leaf: Leaf, sender: UIGestureRecognizer) {
    if let view = leaf.view where !animating {
      var finger: CGPoint = CGPoint()
      if let parentView = leaf.parentView(), startPoint = leaf.moveStartPoint {
        print("Move start Point: \(startPoint)")
        parentView.bringSubviewToFront(view)
        finger = sender.locationInView(parentView)
        print("new point: \(finger)")
        let xDiff = finger.x - startPoint.x
        let yDiff = finger.y - startPoint.y
        leaf.moveStartPoint = finger
        
        if (leaf.grouping != nil) && !(finger.x < parentView.frame.width - Leaf.standardWidth / 2 && finger.x > 0 + Leaf.standardWidth / 2 && finger.y < parentView.frame.height - Leaf.standardHeight / 2 && finger.y > 0 + Leaf.standardHeight / 2) {
          animateLeafGroupingExchange(finger, leaf: leaf, parentView: parentView, sender: sender)
        } else {
          leaf.view?.center.x += xDiff
          leaf.view?.center.y += yDiff
          leaf.changed(.Updated)
          self.profileDelegate?.changesMade()
        }
      }
      
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
  
  func connectionsBeingDrawn(fromObject: TreeObject, sender: UIGestureRecognizer) {
    if let anchor = findExistingConnectionsForObject(fromObject) {
      //should only be one in this case if it gets found....
      updateConnection(anchor, sender: sender)
    } else {
      drawConnection(fromObject, sender: sender, existingConnection: nil)
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
                anchor.connection.toObject = storedLeaf
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
                anchor.connection.toObject = storedGrouping
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
          if let arrow = anchor.connection.arrow {
            arrow.removeFromSuperview()
          }
          if let arrow = anchor.connection.arrow {
            arrow.removeFromSuperview()
          }
//          PeatContentStore.sharedStore.removeConnection(anchor.connection)
        } else {
          // set the point relative to the other views center
          if let _ = anchor.connection.toObject {
            // update the existing connection toObject
            updateExistingConnectionEndpoints(anchor.connection)
            checkForNewCompletions()
          } else {
            updateNewConnectionToEdge(anchor.connection)
          }
        }
      } else {
        anchor.connection.arrow?.removeFromSuperview()
        anchor.connection.connectionLayer?.removeFromSuperlayer()
        if let _ = anchor.connection.toObject {
          updateExistingConnectionEndpoints(anchor.connection)
        } else {
          drawConnection(anchor.object, sender: sender, existingConnection: anchor.connection)
        }
      }
    }
  }

  //For when objects are being moved around
  func updateExistingConnectionEndpoints(connection: LeafConnection) {
    if let toObject = connection.toObject, fromObject = connection.fromObject, toView = toObject.viewForTree(), fromView = fromObject.viewForTree(), parentView = fromObject.parentView() {
      
      //      if toObject.isSelected() {
      //its going to the finger not the views center.........
      let e = Leaf.standardExpand
      var toScaleOffset = CGPoint(x: 0, y: 0)
      if toObject.isSelected() {
        let wE = toView.frame.width * e
        let hE = toView.frame.height * e
        toScaleOffset = CGPoint(x: wE - toView.frame.width, y: hE - toView.frame.height)
      }
      let toOffset = findAdjustedCenter(toView, scalingOffset: toScaleOffset, point: fromView.center)
      let toPlacement = CGPoint(x: toView.center.x + toOffset.x, y: toView.center.y + toOffset.y)
      
      
      let fromScaleOffset = CGPoint(x: 0, y: 0)
      if fromObject.isSelected() {
        let wE = fromView.frame.width * e
        let hE = fromView.frame.height * e
        toScaleOffset = CGPoint(x: wE - fromView.frame.width, y: hE - fromView.frame.height)
      }
      let fromOffset = findAdjustedCenter(fromView, scalingOffset: fromScaleOffset, point: toView.center)
      let fromPlacement =  CGPoint(x: fromView.center.x + fromOffset.x, y: fromView.center.y + fromOffset.y)
      
      connection.connectionLayer?.removeFromSuperlayer()
      connection.arrow?.removeFromSuperview()
      
      let connectionUI: (layer: CAShapeLayer, arrow: UIImageView) = constructConnection(fromPlacement, toPoint: toPlacement, existingConnection: connection)
      connection.connectionLayer = connectionUI.layer
      connection.arrow = connectionUI.arrow
      connection.toObjectPoint = toOffset
      parentView.layer.addSublayer(connectionUI.layer)
      parentView.addSubview(connectionUI.arrow)
      
    }
  }
  
  func updateNewConnectionToEdge(connection: LeafConnection) {
    // set new connection toObject
    if let fromView = connection.fromObject?.viewForTree(), toView = connection.toObject?.viewForTree(), fromOffset = connection.fromObjectPoint, parentView = connection.fromObject?.parentView() {
      // its gotta have a fromOffset here
      // so you need the vector to the from offset of the other view, then you need to run it through the toObject view to find where the connection should go
      let fromPoint = CGPoint(x: fromView.center.x + fromOffset.x, y: fromView.center.y + fromOffset.y)
      let toOffset = findAdjustedCenter(toView, scalingOffset: nil, point: fromPoint)
      let center = CGPoint(x: toView.center.x + toOffset.x, y: toView.center.y + toOffset.y)
      
      connection.connectionLayer?.removeFromSuperlayer()
      connection.arrow?.removeFromSuperview()
      
      let connectionUI: (layer: CAShapeLayer, arrow: UIImageView) = constructConnection(fromPoint, toPoint: center, existingConnection: connection)
      connection.connectionLayer = connectionUI.layer
      connection.arrow = connectionUI.arrow
      connection.toObjectPoint = toOffset
      parentView.layer.addSublayer(connectionUI.layer)
      parentView.addSubview(connectionUI.arrow)
    }
  }
  
  func findAdjustedCenter(view: UIView, scalingOffset: CGPoint?, point: CGPoint) -> CGPoint {
    // this is only for when the to/from points are nil. otherwise we keep those points. (the points have to be relative to the view I guess...
    // UPGRADE (so its not choppy) take a unit circle, rotate it 45 degrees, and then check the value of the angle the vector makes with the rotated center. except its not a square...... hmmm.... this might be the best we can do, not as fancy without the angles but w.e the slope is more useful
    var center = view.center
    if let scalingOffset = scalingOffset {
      center.x -= scalingOffset.x
      center.y -= scalingOffset.y
    }
    let w: CGFloat = view.frame.width / 2
    let h: CGFloat = view.frame.height / 2
    //the fuking translations kill it now..... Maybe when deslecting leaves we need to tweak the connection endpoints?
    let connectionWidth: CGFloat = LeafConnection.standardLayerWidth / 2
    
    let vector: CGPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
    let slope = vector.y / vector.x
    
    //if it is less than
    let greaterThanY = point.y > center.y + h
    let greaterThanX = point.x > center.x + w
    let lessThanX = point.x < center.x - w
    let lessThanY = point.y < center.y - h
    var withinY = false
    if !greaterThanY && !lessThanY { withinY = true }
    var withinX = false
    if !greaterThanX && !lessThanX { withinX = true }
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
  
    if (withinX && greaterThanY) || (lessThanX && greaterThanY) || (greaterThanX && greaterThanY) {
      //on the bottom
      x = h / slope
      y = h - connectionWidth
    } else if (withinX && lessThanY) || (lessThanX && lessThanY) || (greaterThanX && lessThanY) {
      //on the top
      x = -(h / slope)
      y = -(h - connectionWidth)
    } else if withinY && lessThanX {
      //on the left
      x = -(w - connectionWidth)
      y = -(w * slope)
    } else if withinY && greaterThanX {
      //on the right
      x = w - connectionWidth
      y = w * slope
    }
    
    if x > w { x = w - connectionWidth }
    if x < -w { x = -w + connectionWidth }
    
//    fromObject.setConnectionOffsets((x: x, y: y))
    
    return CGPoint(x: x, y: y)
    
    //need to save these points. and then move them relative to where the center of the view is moving.
    //maybe just save the x and y offsets from the center
    // then every time just add that to where the center is
    //hopefully groupings will scale well. yeah they should.
  }
  
  // Drawing from tree
  func drawConnection(fromObject: TreeObject, sender: UIGestureRecognizer, existingConnection: LeafConnection?) {
    if let view = fromObject.viewForTree(), parentView = fromObject.parentView(){
      let finger = sender.locationInView(parentView)
      let offsetPoint = findAdjustedCenter(view, scalingOffset: nil, point: finger)
      let center = CGPoint(x: view.center.x + offsetPoint.x, y: view.center.y + offsetPoint.y)

      if let existing = existingConnection {
        let connectionUI: (layer: CAShapeLayer, arrow: UIImageView) = constructConnection(center, toPoint: finger, existingConnection: existing)
        existing.connectionLayer = connectionUI.layer
        existing.arrow = connectionUI.arrow
        existing.fromObjectPoint = offsetPoint
        parentView.layer.addSublayer(connectionUI.layer)
        parentView.addSubview(connectionUI.arrow)
      } else {
        let connectionUI: (layer: CAShapeLayer, arrow: UIImageView) = constructConnection(center, toPoint: finger, existingConnection: nil)
        let newConnection = LeafConnection.newConnection(connectionUI.layer, arrow: connectionUI.arrow, from: fromObject, to: nil, delegate: self)
        newConnection.fromObjectPoint = offsetPoint
        sharedStore().addConnection(newConnection)
        parentView.layer.addSublayer(connectionUI.layer)
        parentView.addSubview(connectionUI.arrow)
      }
    }
  }
  
  // Drawing from json
  func drawJsonConnection(connection: LeafConnection) {
    if let fromObject = connection.fromObject, toObject = connection.toObject, fromView = fromObject.viewForTree(), toView = toObject.viewForTree(), parentView = fromObject.parentView() where connection.changeStatus != .Removed {
      let connectUI: (layer: CAShapeLayer, arrow: UIImageView) = constructConnection(fromView.center, toPoint: toView.center, existingConnection: connection)
      connection.connectionLayer = connectUI.layer
      connection.arrow = connectUI.arrow
      parentView.layer.addSublayer(connectUI.layer)
      parentView.addSubview(connectUI.arrow)
    }
  }
  
  func constructConnection( fromPoint: CGPoint, toPoint: CGPoint, existingConnection: LeafConnection? ) -> (layer: CAShapeLayer, arrow: UIImageView) {
    let type = existingConnection?.type != nil ? existingConnection!.type! : .Pre
    
    let path = UIBezierPath()
    path.moveToPoint(fromPoint)
    path.addLineToPoint(toPoint)
    let vector = CGPointMake(toPoint.x - fromPoint.x, toPoint.y - fromPoint.y)
    let halfwayPointX = toPoint.x - ((toPoint.x - fromPoint.x) / 2)
    let halfwayPointY = toPoint.y - ((toPoint.y - fromPoint.y) / 2)
    let start = CGPointMake(halfwayPointX, halfwayPointY)
    let arrow = UIImageView(frame: CGRectMake(0,0, Leaf.standardHeight / 1.5, Leaf.standardHeight / 1.5))
    arrow.center.x = start.x
    arrow.center.y = start.y
    
    let n = normalize(vector)
    let nA = CGPointMake(0,1)
    let product = dotProduct(n, b: nA)
    var theta = acos(product)
    // need to rotate from the other way depending on inflection point
    if toPoint.x > fromPoint.x {
      theta *= -1
    }
    
    //need to point it towards what it needs to be pointing towards basically.... so an exisitng connectiino has the to and from points right?
    //always points to the from point. BUT if the from point is the fromObject you want to reverse it
    if let connection = existingConnection, fromObject = connection.fromObject {
      let fromSelected = fromObject.isSelected()
      switch type {
      case .Pre:
        arrow.image = UIImage(named: "up-arrow")
        if !fromSelected || connection.toObject == nil {
          let opposite: Int = 180
          theta += opposite.degreesToRadians
        }
      case .Post:
        arrow.image = UIImage(named: "up-arrow")
        if fromSelected {
          let opposite: Int = 180
          theta += opposite.degreesToRadians
        }
      case .Even:
        //TODO: have an equals image of some kind that straddles the line
        arrow.image = nil
      }
    } else {
      switch type {
      case .Pre:
        arrow.image = UIImage(named: "up-arrow")
        let opposite: Int = 180
        theta += opposite.degreesToRadians
      case .Post:
        arrow.image = UIImage(named: "up-arrow")
      case .Even:
        //TODO: have an equals image of some kind that straddles the line
        arrow.image = nil
      }
    }
    
    let rotation = CGAffineTransformMakeRotation(theta)
    arrow.transform = rotation
    arrow.layer.zPosition = -199
    
    let shapeLayer = CAShapeLayer()
    shapeLayer.path = path.CGPath
    //TODO: send more data down with leaves to tree so we know if they are completed and how many completions there are
    //basically separate request for comments (this is a refactor)
    var color = UIColor.grayColor().CGColor
    if let toObject = existingConnection?.toObject {
      if toObject.isCompleted() {
        color = UIColor.greenColor().CGColor
      }
    }
    shapeLayer.strokeColor = color
    shapeLayer.zPosition = -200
    shapeLayer.lineWidth = LeafConnection.standardLayerWidth
    
    return (layer: shapeLayer, arrow: arrow)
  }
  
  
  func checkForNewCompletions() {
    if let connections = self.store?.treeStore.currentConnections {
      connections.forEach({ (connection) -> () in
        connection.setCompletionColor()
      })
    }
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  //MARK: Groupings
  
  func groupingBeingMoved(grouping: LeafGrouping, sender: UIGestureRecognizer) {
    if let view = grouping.view, startPoint = grouping.moveStartPoint {
//      let centerX = LeafGrouping.standardWidth / 2
//      let centerY = LeafGrouping.standardHeight / 2
      let finger = sender.locationInView(self.treeView)
      let xDiff = finger.x - startPoint.x
      let yDiff = finger.y - startPoint.y
      grouping.moveStartPoint = finger
      
      self.treeView.bringSubviewToFront(view)
      
//      let newCenter = CGPoint(x: finger.x + xDiff, y: finger.y + yDiff)
      
      grouping.view?.center.x += xDiff
      grouping.view?.center.y += yDiff
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
      if CGRectContainsPoint(groupingView.frame, leafView.center) {
        //add leaf to
        leaf.prepareForGrouping()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
          leafView.transform = CGAffineTransformMakeScale(Leaf.standardExpand + 0.2, Leaf.standardExpand + 0.2)
          }, completion: { (complete) -> Void in
            UIView.animateWithDuration(1, animations: { () -> Void in
              leafView.transform = CGAffineTransformIdentity
              }, completion: { (complete) -> Void in
                leafView.center.x -= groupingView.frame.origin.x
                leafView.center.y -= groupingView.frame.origin.y
                groupingView.addSubview(leafView)
                leaf.grouping = grouping
                leaf.moveStartPoint = leafView.center
                leaf.animating = false
                self.checkForNewCompletions()
            })
        })
      }
    }
  }
  
  func newGrouping(timer: NSTimer) {
    if let info = timer.userInfo as? Dictionary<String, AnyObject>, leaf = info["leaf"] as? Leaf, view = leaf.view, lowerLeaf = info["lowerLeaf"] as? Leaf, center = lowerLeaf.view?.center {
      if CGRectContainsPoint(view.frame, center) {
        leaf.prepareForGrouping()
      // check if they interesect first
        let newGrouping = LeafGrouping.newGrouping(center, delegate: self)
        newGrouping.drawGrouping()
        addLeavesToGrouping(newGrouping, lowerLeaf: lowerLeaf, selectedLeaf: leaf)
        leaf.grouping = newGrouping
        lowerLeaf.grouping = newGrouping
//        leaf.deselectLeaf()
        self.profileDelegate?.changesMade()
        leaf.changed(.Updated)
        lowerLeaf.changed(.Updated)
        newGrouping.changed(.BrandNew)
      }
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
  
  func addLeavesToGrouping(grouping: LeafGrouping, lowerLeaf: Leaf, selectedLeaf: Leaf) {
    if let groupingView = grouping.view {
      if let lowerView = lowerLeaf.view {
        groupingView.addSubview(lowerView)
        lowerView.frame = CGRectMake(10,10, Leaf.standardWidth, Leaf.standardHeight)
        lowerLeaf.grouping = grouping
      }
      if let selectedView = selectedLeaf.view {
        groupingView.addSubview(selectedView)
        selectedView.frame = CGRectMake(10,Leaf.standardHeight + 20, Leaf.standardWidth, Leaf.standardHeight)
        selectedLeaf.grouping = grouping
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
//      checkForOverlaps(leaf)
    }
  }
  
  func addLeafToGrouping(leaf: Leaf, grouping: LeafGrouping) {
    if let leafView = leaf.view, groupingView = grouping.view {
      groupingView.addSubview(leafView)
      leaf.grouping = grouping
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
        self.drawJsonConnection(connection)
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
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  //MARK: General

  func fetchTreeData() {
    //right now it redraws every time... no harm in that
    for view in self.treeView.subviews {
      view.removeFromSuperview()
    }
    clearView()
    
//    if let connections = self.store?.treeStore.currentConnections {
//      connections.forEach({ (connection) -> () in
//        connection.connectionLayer?.removeFromSuperlayer()
//      })
//    }
    //In the future get the data for the selected user and the selected activity
    if let activity = self.currentActivity {
      sharedStore().getTreeData(self, viewing: viewing, activity: activity){ (success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.configureScrollView()
          })
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
  
  func newLeafInitiated(sender: UIGestureRecognizer) {
    let center: CGPoint = sender.locationInView(self.treeView)
    if sender.state == .Ended {
      //the last leaf they were placing is done
      self.newLeaf = nil
    } else {
      if let newLeaf = newLeaf {
        newLeaf.view?.center = center
        //move the newLeafs position
      } else {
        print("New leaf initiated: \(center)")
        newLeaf = Leaf.initFromTree(center, delegate: self)
        newLeaf!.generateBounds()
        newLeaf!.changed(.BrandNew)
        newLeaf!.movingEnabled = true
        newLeaf!.drawLeafSelected()
        self.profileDelegate?.changesMade()
      }
    }
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
      if let arrow = connection.arrow {
        arrow.removeFromSuperview()
      }
      drawJsonConnection(connection)
    }
  }
  
//  func setCurrentActivityTree(activity: Activity) {
//    self.currentActivity = activity
//    fetchTreeData()
//  }
  
  func viewForTree() -> UIView? {
    return self.treeView
  }
  
  
  ///MARK: Navigation
  func showGallery(viewing: User?) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let vc = storyboard.instantiateViewControllerWithIdentifier("GalleryCollectionViewController") as? GalleryCollectionViewController {
      vc.setForStackedView()
      vc.profileDelegate = profileDelegate
      profileDelegate?.galleryController = vc
      if let store = self.profileDelegate?.store {
        vc.store = store
      }
      self.navigationController?.pushViewController(vc, animated: false)
    }
  }
  
  //MARK: OVERLAY VIEWS
  
  //MARK: InitiationView
  func configureLeafInitiationView() {
    initiationButton = UIImageView(frame: CGRectMake(10,10,20,20))
    initiationButton!.gestureRecognizers?.removeAll()
    initiationButton!.backgroundColor = UIColor.whiteColor()
    initiationButton!.layer.cornerRadius = 13
    initiationButton!.layer.cornerRadius = initiationButton!.frame.size.height/2
    initiationButton!.clipsToBounds = true
    initiationButton!.layer.masksToBounds = false
    initiationButton!.userInteractionEnabled = true
    initiationButton!.layer.shadowColor = UIColor.blackColor().CGColor
    initiationButton!.layer.shadowOpacity = 0.8
    initiationButton!.layer.shadowRadius = 3.0
    initiationButton!.layer.shadowOffset = CGSizeMake(4, 4)
//
    let panRecognizer = UIPanGestureRecognizer(target: self, action: "newLeafInitiated:")
    initiationButton!.addGestureRecognizer(panRecognizer)
    
//    initiationView!.layer.zPosition = 300
//    self.view.gestureRecognizers?.removeAll()
    self.view.addSubview(initiationButton!)
  }
  
  func drawSizeIncreasers() {
    
    let arrow = UIImage(named: "up-arrow")
    let inset: CGFloat = 35.0
    let sizeX: CGFloat = 40.0
    let sizeY: CGFloat = 20.0
    
    // width
    let wx: CGFloat = self.view.frame.width - inset
    //TODO: fix this
    let wy: CGFloat = 200
    widthIncreaseButton = UIImageView(frame: CGRectMake(wx, wy, sizeX, sizeY))
    widthIncreaseButton!.image = arrow
    widthIncreaseButton!.userInteractionEnabled = true
    widthIncreaseButton!.tintColor = UIColor.blackColor()
    let angleW = 90
    let wR = angleW.degreesToRadians
    let wT = CGAffineTransformMakeRotation(wR)
    widthIncreaseButton!.transform = wT
    widthIncreaseButton!.backgroundColor = UIColor.clearColor()
    let tapRecognizer = UITapGestureRecognizer(target: self, action: "widthIncreaseTapped")
    tapRecognizer.numberOfTapsRequired = 1
    tapRecognizer.numberOfTouchesRequired = 1
    widthIncreaseButton!.hidden = true
    widthIncreaseButton!.addGestureRecognizer(tapRecognizer)
    self.view.addSubview(widthIncreaseButton!)
    
    // height
    let hx: CGFloat = self.view.frame.width / 2 - 10
    //TODO: fix this
    let hy: CGFloat = 435
    heightIncreaseButton = UIImageView(frame: CGRectMake(hx, hy, sizeX, sizeY))
    heightIncreaseButton!.image = arrow
    heightIncreaseButton!.userInteractionEnabled = true
    let angleH = 180
    let hR = angleH.degreesToRadians
    let hT = CGAffineTransformMakeRotation(hR)
    heightIncreaseButton!.transform = hT
    heightIncreaseButton!.tintColor = UIColor.blackColor()
    let tapRecognizerH = UITapGestureRecognizer(target: self, action: "heightIncreaseTapped")
    tapRecognizerH.numberOfTapsRequired = 1
    tapRecognizerH.numberOfTouchesRequired = 1
    heightIncreaseButton!.hidden = true
    heightIncreaseButton!.addGestureRecognizer(tapRecognizerH)
    self.view.addSubview(heightIncreaseButton!)
    
  }
  
  func heightIncreaseTapped() {
    print("Height increase tapped")
    increaseScrollView(forHeight: true)
  }
  
  func widthIncreaseTapped() {
    print("Width increase tapped")
    increaseScrollView(forHeight: false)
  }
  
  func toggleWidthIncreaseOption(show: Bool) {
    widthIncreaseButton?.hidden = show
  }
  
  func toggleHeightIncreaseOption(show: Bool) {
    heightIncreaseButton?.hidden = show
  }
  

}
