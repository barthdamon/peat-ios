//
//  MenuTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/8/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

enum MenuMode {
  case Notification
  case Settings
  //add request mode for tag requests
}

class MenuTableViewController: UITableViewController {
  
  var rootController: RootViewController?
  var API = APIService.sharedService
  var mode: MenuMode = .Notification
  
  var settingsNavItems: Array<String> = ["Log Out", "Edit Profile"]
  
  var notifications: Array<Notification> = []

  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavBar()
    loadNotifications()
  }
  
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func loadNotifications() {
    NotificationHelper.sharedHelper.getNotifications { (notifications) -> () in
      self.notifications = notifications
      print("recieved notifications")
      self.reload()
    }
  }
  
  func loadSettings() {
    self.mode = .Settings
    self.reload()
  }
  
  func configureNavBar() {
    let navOptionView = UIView(frame: CGRectMake(-200,0,300,20))
    
    let notificationsImage = UIImage(named:"notifications")
    let settingsImage = UIImage(named:"settings")
    
    let notificationsButton:UIButton = UIButton(frame: CGRect(x: 0,y: -35,width: 80, height: 80))
    notificationsButton.setBackgroundImage(notificationsImage, forState: .Normal)
    notificationsButton.addTarget(self, action: Selector("showNotifications:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    let settingsButton:UIButton = UIButton(frame: CGRect(x: 50,y: -35,width: 80, height: 80))
    settingsButton.setBackgroundImage(settingsImage, forState: .Normal)
    settingsButton.addTarget(self, action: Selector("showSettings:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    navOptionView.addSubview(notificationsButton)
    navOptionView.addSubview(settingsButton)

    navOptionView.backgroundColor = UIColor.clearColor()
    self.navigationItem.titleView = navOptionView
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
  }
  
  @IBAction func showNotifications(sender: AnyObject) {
    print("Notifications Selected")
    loadNotifications()
  }
  
  @IBAction func showSettings(sender: AnyObject) {
    print("Settings Selected")
    loadSettings()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    switch mode {
    case .Notification:
      return 1
    case .Settings:
      return 1
    }
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch mode {
    case .Notification:
      return "Notifications"
    case .Settings:
      return "Settings"
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    switch mode {
    case .Notification:
      return self.notifications.count
    case .Settings:
      return self.settingsNavItems.count
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 60
  }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      switch mode {
      case .Notification:
        if let cell = tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as? NotificationTableViewCell {
          do {
            let notification = try notifications.lookup(UInt(indexPath.row))
            cell.configureWithNotification(notification)
          }
          catch {
            return defaultCell(tableView, message: "No Notifications Found")
          }
        }
      case .Settings:
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath)
        cell.textLabel?.text = self.settingsNavItems[indexPath.row]
        return cell
      }
      
      return defaultCell(tableView, message: "No Items Found")
    }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch mode {
    case .Notification:
      do {
        let notification = try notifications.lookup(UInt(indexPath.row))
        self.rootController?.segueForNotification(notification)
      }
      catch {
        print("No action for selected item")
      }
    case .Settings:
      if settingsNavItems[indexPath.row] == "Log Out" {
        CurrentUser.info.logOut()
      } else {
        self.rootController?.showEditProfile()
      }
    }
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
