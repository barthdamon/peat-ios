//
//  SideMenuClient.swift
//  Peat
//
//  Created by Matthew Barth on 11/8/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

protocol ViewControllerWithMenu {
  func configureMenuSwipes()
  func initializeSidebar()
  func configureNavBar()
}

class SideMenuClient {
  
  var clientController: UIViewController!
  var tabBar: UITabBarController?
  var menuCloseTapGesture: UITapGestureRecognizer?
  var mainContainer: UIView!
  
  init(clientController: UIViewController, tabBar: UITabBarController?) {
    self.clientController = clientController
    if let mainContainer = globalMainContainer {
      self.mainContainer = mainContainer
    }
    if let tabBar = tabBar {
      self.tabBar = tabBar
    }
  }
  
  func configureNavBar() {
    let mainLogoImage = UIImage(named: "menuIcon.png")
    let cameraImage = UIImage(named: "camera.png")
    //    let imgWidth = infoImage?.size.width
    //    let imgHeight = infoImage?.size.height
    let logoButton: UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: 40, height: 40))
    logoButton.setBackgroundImage(mainLogoImage, forState: .Normal)
    logoButton.layer.cornerRadius = 10.0
    logoButton.clipsToBounds = true
    logoButton.addTarget(self, action: Selector("toggleMenu:"), forControlEvents: UIControlEvents.TouchUpInside)
    clientController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoButton)
    
    let cameraButton: UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: 40, height: 40))
    cameraButton.setBackgroundImage(cameraImage, forState: .Normal)
    cameraButton.layer.cornerRadius = 10.0
    cameraButton.clipsToBounds = true
    cameraButton.addTarget(self, action: Selector("showCameraView:"), forControlEvents: UIControlEvents.TouchUpInside)
    clientController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cameraButton)
    
    clientController?.navigationController?.navigationBar.barTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    clientController?.view.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
  }
  
  func configureMenuSwipes() {
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: "toggleMenu:")
    rightSwipe.direction = .Right
    rightSwipe.numberOfTouchesRequired = 1
    
    clientController?.view.addGestureRecognizer(rightSwipe)
    
    let leftSwipe = UISwipeGestureRecognizer(target: self, action: "toggleMenu:")
    leftSwipe.direction = .Left
    leftSwipe.numberOfTouchesRequired = 1
    
    clientController?.view.addGestureRecognizer(leftSwipe)
    
    let panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
    clientController?.view.addGestureRecognizer(panGesture)
  }
  
  func configureMenuCloseTap() {
    menuCloseTapGesture = UITapGestureRecognizer(target: self, action: "toggleMenu:")
    menuCloseTapGesture!.numberOfTouchesRequired = 1
    menuCloseTapGesture!.numberOfTapsRequired = 1
    clientController?.view.addGestureRecognizer(menuCloseTapGesture!)
    menuCloseTapGesture!.enabled = false
  }
  
  @IBAction func showCameraView(sender: AnyObject) {
    print("Camera Selected")
    if let tabBar = self.tabBar {
      tabBar.selectedIndex = 3
    }
  }
  
  @IBAction func toggleMenu(sender: AnyObject) {
      let offset = clientController.view.frame.width * 0.8
      var offscreen = false
      if sender is UIPanGestureRecognizer {
        offscreen = mainContainer.frame.origin.x < offset / 2
      } else {
        offscreen = mainContainer.frame.origin.x > 0
      }
    
      if sender.isKindOfClass(UISwipeGestureRecognizer) {
        if sender.direction == .Right && offscreen { return }
        if sender.direction == .Left && !offscreen { return }
      }
    
    
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        if offscreen {
          self.mainContainer.frame.origin.x = 0
        } else {
          self.mainContainer.frame.origin.x = 0 + offset
        }
        }, completion: { (complete) -> Void in
        if !offscreen {
          NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "menuAnimationComplete", object: self))
        }
      })
  }
  
  
  @IBAction func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
    let offset = mainContainer.frame.width * 0.8
    if let container = mainContainer {
      if gestureRecognizer.state == UIGestureRecognizerState.Began || gestureRecognizer.state == UIGestureRecognizerState.Changed {
        let translation = gestureRecognizer.translationInView(container)
        if mainContainer.frame.origin.x + translation.x > offset  {return}
        if mainContainer.frame.origin.x + translation.x < 0 {return}
        mainContainer.center = CGPointMake(mainContainer.center.x + translation.x, mainContainer.center.y)
        gestureRecognizer.setTranslation(CGPointMake(0,0), inView: mainContainer)
      } else if gestureRecognizer.state == UIGestureRecognizerState.Ended {
        toggleMenu(gestureRecognizer)
      }
    }
  }
  
}
