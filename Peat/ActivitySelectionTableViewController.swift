//
//  ActivitySelectionTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/16/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class ActivitySelectionTableViewController: UITableViewController, UITextFieldDelegate {
    
    var textField: UITextField?
    var profileVC: ProfileViewController? {
      didSet {
        if let viewing = profileVC!.viewing {
          self.viewing = viewing
          user = viewing
        } else {
          user = CurrentUser.info.model
        }
      }
    }
  
    var viewing: User?
    var user: User?
  
    var matchingActivities: Array<Activity>?
    
    override func viewDidLoad() {
      super.viewDidLoad()
      setDefaultActivities()
      if self.viewing == nil {
        configureTextField()
      }
    }
    
    func configureTextField() {
      let textField = UITextField(frame: CGRectMake(0,0,self.view.frame.width, 40))
      textField.delegate = self
      
      textField.backgroundColor = UIColor.whiteColor()
      textField.placeholder = "Ability Name"
      textField.returnKeyType = .Done
      textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
      self.textField = textField
      self.tableView.tableHeaderView = textField
    }
    
    func textFieldDidChange(textField: UITextField) {
      if let text = textField.text {
        if let user = user {
          if text != "" {
            profileVC?.store.searchForActivities(user, activityTerm: text, callback: { (activities) -> () in
              if let activities = activities {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                  self.matchingActivities = activities
                  self.tableView.reloadData()
                })
              }
            })
          }
        }
      }
    }
  
  func setDefaultActivities() {
    self.matchingActivities = user?.activeActivities
  }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
      if let text = textField.text where text != "" {
        var foundMatch = false
        if let activities = matchingActivities {
          for activity in activities {
            if text == activity.name {
              setProfileActivity(activity)
//              leafDetailVC?.selectedAbility = ability
              foundMatch = true
            }
          }
        }
        if !foundMatch {
          let newActivity = Activity()
          //approval process? Should that even exist.... NO!
          newActivity.name = text
          profileVC?.currentActivity = newActivity
        }
      }
      self.dismissViewControllerAnimated(true, completion: nil)
      return true
    }
  
  func setProfileActivity(activity: Activity) {
    profileVC?.currentActivity = activity
    //reload the profileVC treeViewControllers data
    profileVC?.reinitializeTreeController()
  }
  
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      // #warning Incomplete implementation, return the number of sections
      return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of rows
      return matchingActivities != nil ? matchingActivities!.count : 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("abilityCell", forIndexPath: indexPath)
      if let activities = self.matchingActivities {
        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.name
      }
      return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      if let activities = self.matchingActivities {
        let selectedActivity = activities[indexPath.row]
        setProfileActivity(selectedActivity)
        self.dismissViewControllerAnimated(true, completion: nil)
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
