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
        super.viewDidLoad()

      // Do any additional setup after loading the view.
      scrollView.contentSize.height = 1000
      scrollView.contentSize.width = 1000
      
      let coordinateArray: [(x: CGFloat, y: CGFloat)] = [(x: 100 , y: 100), (x: 150, y: 200), (x: 200, y: 300), (x: 100, y: 500), (x: 300, y: 500)]
      
      for pair in coordinateArray {
        let leaf = LeafNode(coords: pair, delegate: self)
        leaves.append(leaf)
      }
      
      var previous = 0
      for var i = 1; i < leaves.count; i++  {
        connectAbilities(from: leaves[previous], to: leaves[i])
        previous = i
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func connectAbilities(from leafA: LeafNode, to leafB: LeafNode) {
    if let centerA = leafA.center, centerB = leafB.center {
      let path = UIBezierPath()
      path.moveToPoint(centerA)
      path.addLineToPoint(centerB)
      
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      shapeLayer.strokeColor = UIColor.greenColor().CGColor
      shapeLayer.lineWidth = 3.0
      shapeLayer.fillColor = UIColor.blackColor().CGColor
      //LOL @SETH
      shapeLayer.zPosition = -1
      
      scrollView.layer.addSublayer(shapeLayer)
    }
  }
  
  func addLeafToScrollView(leafView: UIView) {
    self.scrollView.addSubview(leafView)
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
