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
  var leaves: [Leaf] = Array()
  var selectedLeaf: Leaf?
  var changesMade: Bool = false

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var saveButton: UIButton!
  
  
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
  
  func configureScrollView() {
    
    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "newLeafInitiated:")
    doubleTapRecognizer.numberOfTouchesRequired = 1
    doubleTapRecognizer.numberOfTapsRequired = 2
    scrollView.addGestureRecognizer(doubleTapRecognizer)
    
//    var doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
//    doubleTapRecognizer.numberOfTapsRequired = 2
//    doubleTapRecognizer.numberOfTouchesRequired = 1
//    scrollView.addGestureRecognizer(doubleTapRecognizer)
    scrollView.contentSize.height = 1000
    scrollView.contentSize.width = 1000
  }
  
  func setChangesMade() {
    if !changesMade {
      changesMade = true
//      self.saveButton.hidden = false
    }
  }
  
  func addLeafToScrollView(leaf: Leaf) {
    if let view = leaf.view {
      self.leaves.append(leaf)
      self.scrollView.addSubview(view)
      checkForOverlaps(leaf)
    }
  }
  
  func leafBeingMoved(leaf: Leaf, sender: UIGestureRecognizer) {
    if let view = leaf.view {
      setChangesMade()
      self.scrollView.bringSubviewToFront(view)
      let center = sender.locationInView(self.scrollView)
      leaf.view?.center = center
    }
    //allow the leaf to move with the gesture until the gesture is finished, then place the leaf and remove the shadow
  }
  
  func checkForOverlaps(intruder: Leaf) {
    for leaf in leaves {
      if leaf != intruder {
        if let intruderView = intruder.view, leafView = leaf.view {
          if CGRectIntersectsRect(leafView.frame, intruderView.frame) {
            //TODO: offset these more intelligently
            intruderView.center.x += Leaf.standardWidth
            intruderView.center.y += Leaf.standardHeight
            let newOffsetX = intruderView.center.x - self.scrollView.frame.width / 2
            let newOffsetY = intruderView.center.y - self.scrollView.frame.height / 2
            self.scrollView.setContentOffset(CGPointMake(newOffsetX, newOffsetY), animated: true)
            checkForOverlaps(intruder)
          }
        }
      }
    }
  }
  
  func displayLeaves() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      for leaf in self.leaves {
        leaf.treeDelegate = self
        leaf.generateBounds()
        leaf.drawConnections()
      }
    })
  }

  func fetchTreeData() {
    //right now it redraws every time... no harm in that
    //In the future get the data for the selected user and the selected activity
    PeatContentStore.sharedStore.getTreeData("Snowboarding", delegate: self){ (res, err) -> () in
      if let e = err {
        print("ERROR: \(e)")
        //show error view
      } else {
        self.leaves = PeatContentStore.sharedStore.abilityStore.currentLeaves
        self.displayLeaves()
      }
    }
  }
  
  func drawConnectionLayer(connection: CAShapeLayer) {
    scrollView.layer.addSublayer(connection)
  }
  
  func drillIntoLeaf(leaf: Leaf) {
    selectedLeaf = leaf
    performSegueWithIdentifier("leafDrilldown", sender: self)
  }
  
  func newLeafInitiated(sender: UILongPressGestureRecognizer) {
    print("Sender: \(sender)")
    let center: CGPoint = sender.locationInView(self.scrollView)
    print("SENDER: \(center)")
    let newLeaf = Leaf.initFromTree(center, delegate: self)
    newLeaf.generateBounds()
    setChangesMade()
  }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
      if segue.identifier == "leafDrilldown" {
        if let vc = segue.destinationViewController as? LeafDetailTableViewController {
          vc.leaf = self.selectedLeaf
        }
      }
      
    }
  @IBAction func saveButtonPressed(sender: AnyObject) {
    //save to the db
  }
}
