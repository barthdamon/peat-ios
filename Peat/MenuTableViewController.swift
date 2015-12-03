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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      configureNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
  
  func configureNavBar() {
    let navOptionView = UIView(frame: CGRectMake(-200,0,300,40))
    
    let newsfeedImage = UIImage(named:"newsfeed.png")
    let treeImage = UIImage(named:"tree.png")
    let friendsImage = UIImage(named:"friends.png")
    
    let newsfeedButton:UIButton = UIButton(frame: CGRect(x: 0,y: 0,width: 40, height: 40))
    newsfeedButton.setBackgroundImage(newsfeedImage, forState: .Normal)
    newsfeedButton.addTarget(self, action: Selector("showNewsfeed:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    let treeButton:UIButton = UIButton(frame: CGRect(x: 50,y: 0,width: 40, height: 40))
    treeButton.setBackgroundImage(treeImage, forState: .Normal)
    treeButton.addTarget(self, action: Selector("showTree:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    let friendsButton:UIButton = UIButton(frame: CGRect(x: 100,y: 0,width: 40, height: 40))
    friendsButton.setBackgroundImage(friendsImage, forState: .Normal)
    friendsButton.addTarget(self, action: Selector("showFriends:"), forControlEvents: UIControlEvents.TouchUpInside)
    
    navOptionView.addSubview(newsfeedButton)
    navOptionView.addSubview(treeButton)
    navOptionView.addSubview(friendsButton)
    
    navOptionView.backgroundColor = UIColor.clearColor()
    self.navigationItem.titleView = navOptionView
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
  }
  
  @IBAction func showNewsfeed(sender: AnyObject) {
    print("Newsfeed Selected")
    if let tabBar = self.rootController?.mainTabBarController {
      tabBar.selectedIndex = 0
      NSNotificationCenter.defaultCenter().postNotificationName("navItemSelected", object: nil, userInfo: nil)
    }
  }
  
  @IBAction func showTree(sender: AnyObject) {
    print("Tree Selected")
    if let tabBar = self.rootController?.mainTabBarController {
      tabBar.selectedIndex = 2
      NSNotificationCenter.defaultCenter().postNotificationName("navItemSelected", object: nil, userInfo: nil)
    }
  }
  
  @IBAction func showFriends(sender: AnyObject) {
    print("Friends Selected")
    if let tabBar = self.rootController?.mainTabBarController {
      tabBar.selectedIndex = 1
      NSNotificationCenter.defaultCenter().postNotificationName("navItemSelected", object: nil, userInfo: nil)
    }
  }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
