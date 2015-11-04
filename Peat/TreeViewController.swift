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
  
  

  @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchTreeData", name: "leavesPopulated", object: nil)
        super.viewDidLoad()

      // Do any additional setup after loading the view.
      scrollView.contentSize.height = 1000
      scrollView.contentSize.width = 1000
      
//      let coordinateArray: [(x: CGFloat, y: CGFloat)] = [(x: 100 , y: 100), (x: 150, y: 200), (x: 200, y: 300), (x: 100, y: 500), (x: 300, y: 500)]
//      
//      for pair in coordinateArray {
//        let leaf = LeafNode()
//        leaves.append(leaf)
//      }
      
//      var previous = 0
//      for var i = 1; i < leaves.count; i++  {
//        connectAbilities(from: leaves[previous], to: leaves[i])
//        previous = i
//      }
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
    for leaf in self.leaves {
      leaf.generateBounds()
      leaf.drawConnections()
    }
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
