//
//  HomeViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/8/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
  
  var ourContainerView: UIView?
  var menuCloseTapGesture: UITapGestureRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
      configureNavBar()
      configureMenuSwipes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func configureNavBar() {
    let infoImage = UIImage(named: "menuIcon.png")
    //    let imgWidth = infoImage?.size.width
    //    let imgHeight = infoImage?.size.height
    let button:UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: 40, height: 40))
    button.setBackgroundImage(infoImage, forState: .Normal)
    button.layer.cornerRadius = 10.0
    button.clipsToBounds = true
    button.addTarget(self, action: Selector("toggleMenu:"), forControlEvents: UIControlEvents.TouchUpInside)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
  }
  
  func configureMenuSwipes() {
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: "toggleMenu:")
    rightSwipe.direction = .Right
    rightSwipe.numberOfTouchesRequired = 1
    
    self.view.addGestureRecognizer(rightSwipe)
    
    let leftSwipe = UISwipeGestureRecognizer(target: self, action: "toggleMenu:")
    leftSwipe.direction = .Left
    leftSwipe.numberOfTouchesRequired = 1
    
    self.view.addGestureRecognizer(leftSwipe)
  }
  
  func configureMenuCloseTap() {
    menuCloseTapGesture = UITapGestureRecognizer(target: self, action: "toggleMenu:")
    menuCloseTapGesture!.numberOfTouchesRequired = 1
    menuCloseTapGesture!.numberOfTapsRequired = 1
    self.view.addGestureRecognizer(menuCloseTapGesture!)
    menuCloseTapGesture!.enabled = false
  }
  
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  @IBAction func toggleMenu(sender: AnyObject) {
    let offscreen = self.ourContainerView?.frame.origin.x > 0
    
    if sender.isKindOfClass(UISwipeGestureRecognizer) {
      if sender.direction == .Right && offscreen { return }
      if sender.direction == .Left && !offscreen { return }
    }
    
    let offset = self.view.frame.width * 0.8
    
    UIView.animateWithDuration(0.2, animations: { () -> Void in
      if offscreen {
        self.ourContainerView?.center.x -= offset
      } else {
        self.ourContainerView?.center.x += offset
      }
      }, completion: { (complete) -> Void in
        if !offscreen {
          NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "menuAnimationComplete", object: self))
        }
    })
//    mediaPlayerContainerView.userInteractionEnabled = offscreen
//    featuredCollectionsContainerView.userInteractionEnabled = offscreen
//    promoViewSwipeGesture?.enabled = offscreen
//    menuCloseTapGesture?.enabled = !offscreen
  }
  
  
  @IBAction func testButtonClick(sender: AnyObject) {
    self.performSegueWithIdentifier("showMainViewController", sender: self)
  }
  

}
