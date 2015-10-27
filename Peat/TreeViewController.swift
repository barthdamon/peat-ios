//
//  TreeViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/25/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class TreeViewController: UIViewController {
  
  let standardWidth: CGFloat = 200
  let standardHeight: CGFloat = 100
  var centerX: CGFloat {
    return standardWidth / 2
  }
  var centerY: CGFloat {
    return standardHeight / 2
  }
  
  var frameView: UIView?


  @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

      // Do any additional setup after loading the view.
      scrollView.contentSize.height = 1000
      scrollView.contentSize.width = 1000
      frameView = UIView(frame: CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height))
      
      let x1: CGFloat = 10
      let y1: CGFloat = 10
      let firstCenter = CGPoint(x: centerX + x1, y: centerY + y1)
      createFrame(x1, y1)
      
      let x2: CGFloat = 200
      let y2: CGFloat = 300
      let secondCenter = CGPoint(x: centerX + x2, y: centerY + y2)
      createFrame(x2, y2)
      
      connectAbilities(from: firstCenter, to: secondCenter)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func createFrame(x: CGFloat, _ y: CGFloat) {
    let frame = CGRectMake(x, y, standardWidth, standardHeight)
    let viewToAdd = UIView(frame: frame)
    viewToAdd.backgroundColor = .yellowColor()
    scrollView.addSubview(viewToAdd)
  }
  
  func connectAbilities(from highPoint: CGPoint, to lowPoint: CGPoint) {
      let path = UIBezierPath()
      path.moveToPoint(highPoint)
      path.addLineToPoint(lowPoint)
      
      let shapeLayer = CAShapeLayer()
      shapeLayer.path = path.CGPath
      shapeLayer.strokeColor = UIColor.redColor().CGColor
      shapeLayer.lineWidth = 3.0
      shapeLayer.fillColor = UIColor.blackColor().CGColor
      //LOL @SETH
      shapeLayer.zPosition = -1000
      
      scrollView.layer.addSublayer(shapeLayer)
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
