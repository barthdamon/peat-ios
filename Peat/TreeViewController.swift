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
  var leaves = [LeafNode]()
  var selectedLeaf: LeafNode?


  @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchTreeData", name: "leavesPopulated", object: nil)
        super.viewDidLoad()

      // Do any additional setup after loading the view.
      scrollView.contentSize.height = 1000
      scrollView.contentSize.width = 1000
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
    fetchTreeData()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func addLeafToScrollView(leafView: UIView) {
    self.scrollView.addSubview(leafView)
  }
  
  func fetchTreeData() {
    if !initializeLeaves() {
      PeatContentStore.sharedStore.generateActivityTree(.Trampoline, delegate: self)
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

  func initializeLeaves() -> Bool {
    if let leaves = PeatContentStore.sharedStore.leaves {
      self.leaves = leaves
      displayLeaves()
      return true
    } else {
      return false
    }
  }
  
  func drawConnectionLayer(connection: CAShapeLayer) {
    scrollView.layer.addSublayer(connection)
  }
  
  func drillIntoLeaf(leaf: LeafNode) {
    selectedLeaf = leaf
    performSegueWithIdentifier("leafDrilldown", sender: self)
  }



    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
      if segue.identifier == "leafDrilldown" {
        if let vc = segue.destinationViewController as? LeafDetailViewController {
          vc.leaf = self.selectedLeaf
        }
      }
      
    }


}
