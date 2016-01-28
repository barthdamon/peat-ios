//
//  MenuTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/8/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
  
  var rootController: RootViewController?
  var API = APIService.sharedService
  
  var settingsNavItems: Array<String> = ["Log Out"]
  var notificationItems: Array<String> = ["Example Notification"]
  
  var requestUsers: Array<User>?
  var unconfirmedFriendships: Array<Friendship>?

  var activeItems: Array<String>? {
    didSet {
      self.tableView.reloadData()
    }
  }
  
    override func viewDidLoad() {
      super.viewDidLoad()
      configureNavBar()
      loadNotifications()
    }
  
  func loadNotifications() {
    API.get(nil, url: "mail/requests") { (res, err) -> () in
      if let e = err {
        print("Error fetching requests: \(e)")
      } else {
        if let json = res as? jsonObject {
          if let requestUsers = json["requestUsers"] as? Array<jsonObject> {
            self.requestUsers = Array()
            for user in requestUsers {
              self.requestUsers?.append(User.userFromProfile(user))
            }
          }
          
          if let unconfirmedFriends = json["unconfirmedFriends"] as? Array<jsonObject> {
            self.unconfirmedFriendships = Array()
            for friend in unconfirmedFriends {
              self.unconfirmedFriendships?.append(Friendship.friendFromJson(friend))
            }
          }
          
        }
      }
    }
    self.activeItems = notificationItems
  }
  
  func loadSettings() {
    self.activeItems = settingsNavItems
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
    return self.activeItems != nil ? 1 : 0
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.activeItems != nil ? self.activeItems!.count : 0
  }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath)
        if let activeItems = self.activeItems {
          cell.textLabel?.text = activeItems[indexPath.row]
        }

        return cell
    }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let activeItems = self.activeItems {
      if activeItems[indexPath.row] == "Log Out" {
        CurrentUser.info.logOut()
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
