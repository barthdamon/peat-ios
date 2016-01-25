//
//  ProfileViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/24/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ViewControllerWithMenu {

  var sidebarClient: SideMenuClient?
  var changesPresent: Bool = false
  
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var currentAbilityLabel: UILabel!
  
  var treeController: TreeViewController?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      initializeSidebar()
      configureMenuSwipes()
      configureNavBar()
      CurrentUser.info.fetchProfile(){ (success) in
        if success {
          self.setupUserProfile()
        }
      }
      
    }
  
    func setupUserProfile() {
      print("Setting Up User Profile")
      if let user = CurrentUser.info.model {
        if let first = user.first, last = user.last, username = user.username {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.nameLabel.text = "\(first) \(last)"
            self.usernameLabel.text = username
          })
        }
        
      }
    }
  
    func drillIntoLeaf(leaf: Leaf) {
      PeatContentStore.sharedStore.setSelectedLeaf(leaf)
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
        }
      }
    }
  
  func changesMade(leaf: Leaf) {
    PeatContentStore.sharedStore.leafChanged(leaf)
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
    PeatContentStore.sharedStore.syncTreeChanges({ (success) in
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
  
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    treeController?.fetchTreeData()
    self.changesPresent = false
    self.cancelButton.hidden = true
    self.saveButton.hidden = true
  }
  
}
