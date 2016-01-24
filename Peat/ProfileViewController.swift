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
  var changesPresent: Bool = false {
    didSet {
      self.saveButton.hidden = false
    }
  }
  
  @IBOutlet weak var saveButton: UIButton!
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      initializeSidebar()
      configureMenuSwipes()
      configureNavBar()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        }
      }
    }
  
  func changesMade() {
    if !changesPresent {
      changesPresent = true
    }
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
        self.changesPresent = false
        self.saveButton.hidden = true
      } else {
        alertShow(self, alertText: "Error", alertMessage: "Tree Save Unsuccessful")
      }
    })
  }
}
