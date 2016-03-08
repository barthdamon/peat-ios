//
//  RootViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/8/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

public var globalMainContainer: UIView?

class RootViewController: UIViewController {

  @IBOutlet weak var mainViewContainer: UIView!
  @IBOutlet weak var menuWidthConstraint: NSLayoutConstraint!
  var mainTabBarController: UITabBarController?
  var homeViewController: UIViewController?
  
  var mediaForNotificationSegue: MediaObject?
  var userForNotificationSegue: User?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      configureContainers()
//      SocketService.sharedService.configureSocket()
        // Do any additional setup after loading the view.
      if let tabBar = self.mainTabBarController {
        tabBar.selectedIndex = 2
      }
      self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
  }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "homeViewEmbed" {
        print("homeViewEmbed")
        print(segue.destinationViewController)
        if let tabBarController = segue.destinationViewController as? UITabBarController {
//          tabBarController.tabBar.hidden = true
          self.mainTabBarController = tabBarController
        }
      } else if segue.identifier == "menuEmbed" {
        print("homeMenuEmbed")
        if let navCon = segue.destinationViewController as? UINavigationController,
          vc = navCon.topViewController as? MenuTableViewController {
            vc.rootController = self
        }
      }
      if segue.identifier == "showNotificationProfile" {
        if let vc = segue.destinationViewController as? ProfileViewController {
          vc.viewing = userForNotificationSegue
          vc.stacked = true
          vc.stackedFromRoot = true
        }
      }
      
      if segue.identifier == "showNotificationMedia" {
        if let vc = segue.destinationViewController as? CommentsTableViewController {
          vc.media = mediaForNotificationSegue
        }
      }
    }
  
  func configureContainers() {
    let windowWidth = self.view.frame.width
    menuWidthConstraint.constant = windowWidth * 0.8
    
    mainViewContainer.layer.masksToBounds = false
    mainViewContainer.layer.shadowColor = UIColor.blackColor().CGColor
    mainViewContainer.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    mainViewContainer.layer.shadowOpacity = 0.6
    mainViewContainer.layer.shadowRadius = 5.0
    
    globalMainContainer = mainViewContainer
  }
  
  func showEditProfile() {
    self.performSegueWithIdentifier("showEditProfile", sender: self)
  }
  
  func segueForNotification(notification: Notification) {
    if let type = notification.type {
      switch type {
      case .Witness:
        self.mainTabBarController?.selectedIndex = 1
        // they witnessed the current user... Could take the leaf and auto drilldown into it... probly should.
      case .Tag:
        self.mediaForNotificationSegue = notification.mediaObject
        self.performSegueWithIdentifier("showNotificationMedia", sender: self)
      case .Repost:
        self.mediaForNotificationSegue = notification.mediaObject
        self.performSegueWithIdentifier("showNotificationMedia", sender: self)
      case .Like:
        self.mediaForNotificationSegue = notification.mediaObject
        self.performSegueWithIdentifier("showNotificationMedia", sender: self)
      case .Follow:
        self.userForNotificationSegue = notification.userNotifying
        self.performSegueWithIdentifier("showNotificationProfile", sender: self)
      case .Comment:
        self.mediaForNotificationSegue = notification.mediaObject
        self.performSegueWithIdentifier("showNotificationMedia", sender: self)
      }
    }
  }
  
  func showUserProfile(user: User) {
    self.userForNotificationSegue = user
    self.performSegueWithIdentifier("showNotificationProfile", sender: self)
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
