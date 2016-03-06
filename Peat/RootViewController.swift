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
    if let object = notification.mediaObject {
      self.mediaForNotificationSegue = object
      self.performSegueWithIdentifier("showNotificationMedia", sender: self)
    } else if let type = notification.type  where type == .Witness {
      self.tabBarController?.selectedIndex = 0
      //show your own profile. Or take them to the leaf I suppose....
    } else if let user = notification.userNotifying {
      self.userForNotificationSegue = user
    }
  }
  
  func showUserProfile(user: User) {
    
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
