//
//  ProfileViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/24/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ViewControllerWithMenu, UIPopoverPresentationControllerDelegate {

  var sidebarClient: SideMenuClient?
  var changesPresent: Bool = false
  
  var viewing: User?
  var store = PeatContentStore()
  
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!

  @IBOutlet weak var currentActivityLabel: UILabel!
  
  var treeController: TreeViewController?
  var drilldownController: LeafDetailViewController?
  var currentActivity: Activity? {
    didSet {
      if let activity = currentActivity, name = activity.name {
        self.currentActivityLabel.text = name
      } else {
        self.currentActivityLabel.text = ""
      }
    }
  }
  
  func reinitializeTreeController() {
    treeController?.currentActivity = currentActivity
    treeController?.fetchTreeData()
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      initializeSidebar()
      configureMenuSwipes()
      configureNavBar()
      if let user = viewing {
        setupUserProfile(user)
        treeController?.fetchTreeData()
      } else {
        CurrentUser.info.fetchProfile(){ (success) in
          if success {
            if let user = CurrentUser.info.model {
              self.setupUserProfile(user)
              self.treeController?.fetchTreeData()
            }
          }
        }
      }
    }
  
  func sharedStore() -> PeatContentStore {
    return store
  }
  
  func setupUserProfile(user: User) {
      print("Setting Up User Profile")
      if let username = user.username {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if let first = user.first, last = user.last where user.type == .Single {
            self.nameLabel.text = "\(first) \(last)"
          } else {
            self.nameLabel.hidden = true
          }
          self.usernameLabel.text = username
          if let activities = user.activeActivities {
            self.currentActivity = activities[0]
          }
        })
        
        user.generateAvatarImage({ (image) -> () in
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height / 2
//            self.avatarImageView.clipsToBounds = true
            self.avatarImageView.image = image
            self.avatarImageView.contentMode = .ScaleAspectFit
          })
        })
      }
    }
  
    func drillIntoLeaf(leaf: Leaf) {
      store.setSelectedLeaf(leaf)
      self.performSegueWithIdentifier("leafDrilldown", sender: self)
    }
  

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      if segue.identifier == "treeViewEmbed" {
        if let vc = segue.destinationViewController as? TreeViewController {
          vc.profileDelegate = self
          self.treeController = vc
          vc.viewing = self.viewing
          vc.store = store
          if let activity = currentActivity {
            vc.setCurrentActivityTree(activity)
          }
        }
      }
      
      if segue.identifier == "leafDrilldown" {
        if let nav = segue.destinationViewController as? UINavigationController, vc = nav.topViewController as? LeafDetailViewController {
          vc.viewing = self.viewing
          vc.profileDelegate = self
          self.drilldownController = vc
        }
      }
      
      if segue.identifier == "activitySelectionPopoverSegue" {
        if let vc = segue.destinationViewController as? ActivitySelectionTableViewController {
          vc.profileVC = self
          let popover = vc.popoverPresentationController
          popover?.delegate = self
          vc.popoverPresentationController?.delegate = self
          //        vc.popoverPresentationController?.sourceView = self.view
          //        vc.popoverPresentationController?.sourceRect = CGRectMake(100,100,0,0)
          vc.preferredContentSize = CGSize(width: self.view.frame.width, height: 200)
        }
      }
      
    }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  func changesMade() {
    self.saveButton.hidden = false
    self.cancelButton.hidden = true
  }

  
  //MARK: Sidebar
  func initializeSidebar() {
    self.sidebarClient = SideMenuClient(clientController: self, tabBar: self.tabBarController)
  }
  
  func configureNavBar() {
    sidebarClient?.configureNavBar()
  }
  
  func configureMenuSwipes() {
    sidebarClient?.configureMenuSwipes()
  }

  @IBAction func saveButtonPressed(sender: AnyObject) {
    store.syncTreeChanges({ (success) in
      if success {
        alertShow(self, alertText: "Success", alertMessage: "Tree Saved Successfully")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.saveButton.hidden = true
          self.cancelButton.hidden = true
          self.changesPresent = false
        })
      } else {
        alertShow(self, alertText: "Error", alertMessage: "Tree Save Unsuccessful")
      }
    })
  }
  
  @IBAction func activitySelectButtonPressed(sender: AnyObject) {
    //show activity popover
    self.performSegueWithIdentifier("activitySelectionPopoverSegue", sender: self)
  }
  
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    treeController?.fetchTreeData()
    self.changesPresent = false
    self.cancelButton.hidden = true
    self.saveButton.hidden = true
  }
  
  func dismissDrilldownModal() {
    self.drilldownController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
