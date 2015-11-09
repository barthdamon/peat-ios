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
  var menuCloseTapGesture: UITapGestureRecognizer?
  var mainContainer: UIView!
  
  init(clientController: UIViewController) {
    self.clientController = clientController
    if let mainContainer = globalMainContainer {
      self.mainContainer = mainContainer
    }
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
    clientController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    clientController?.navigationController?.navigationBar.barTintColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
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
  }
  
  func configureMenuCloseTap() {
    menuCloseTapGesture = UITapGestureRecognizer(target: self, action: "toggleMenu:")
    menuCloseTapGesture!.numberOfTouchesRequired = 1
    menuCloseTapGesture!.numberOfTapsRequired = 1
    clientController?.view.addGestureRecognizer(menuCloseTapGesture!)
    menuCloseTapGesture!.enabled = false
  }
  
  @IBAction func toggleMenu(sender: AnyObject) {
    let offscreen = self.mainContainer.frame.origin.x > 0
    
    if sender.isKindOfClass(UISwipeGestureRecognizer) {
      if sender.direction == .Right && offscreen { return }
      if sender.direction == .Left && !offscreen { return }
    }

    let offset = clientController.view.frame.width * 0.7
    
    UIView.animateWithDuration(0.2, animations: { () -> Void in
      if offscreen {
        self.mainContainer.center.x -= offset
      } else {
        self.mainContainer.center.x += offset
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
}
