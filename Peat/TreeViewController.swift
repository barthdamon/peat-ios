//
//  TreeViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/25/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class TreeViewController: UIViewController {
  
  // Tree Standards
  let standardWidth: CGFloat = 200
  let standardHeight: CGFloat = 100
  var centerX: CGFloat {
    return standardWidth / 2
  }
  var centerY: CGFloat {
    return standardHeight / 2
  }
  var frameView: UIView?
  
  // Dynamic Data
  var centerPoints = [CGPoint]()
  
  

  @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

      // Do any additional setup after loading the view.
      scrollView.contentSize.height = 1000
      scrollView.contentSize.width = 1000
      frameView = UIView(frame: CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height))
      
      let coordinateArray: [(x: CGFloat, y: CGFloat)] = [(x: 10 , y: 10), (x: 200, y: 300), (x: 400, y: 600), (x: 700, y: 600), (x: 600, y: 800)]
      
      for pair in coordinateArray {
        let center = CGPoint(x: centerX + pair.x, y: centerY + pair.y)
        centerPoints.append(center)
        createFrame(pair.x, pair.y)
      }
      
      var previous = 0
      for var i = 1; i < centerPoints.count; i++  {
        connectAbilities(from: centerPoints[previous], to: centerPoints[i])
        previous = i
      }
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
