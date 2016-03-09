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
  
  var stacked = false
  var isShowingForGallery = false
  
  var stackedFromRoot = false
  
  @IBOutlet weak var profileModeSelector: UISegmentedControl!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!

  @IBOutlet weak var currentActivityLabel: UILabel!
  
  var treeController: TreeViewController?
  var galleryController: GalleryCollectionViewController?
  var drilldownController: LeafDetailViewController?
  var currentActivity: Activity? {
    didSet {
      if let activity = currentActivity, name = activity.name {
        self.currentActivityLabel.text = name
        self.store.treeStore.currentActivity = currentActivity
        self.treeController?.toggleActive(true)
      } else {
        self.currentActivityLabel.text = ""
      }
    }
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.profileModeSelector.addTarget(self, action: "profileModeChanged:", forControlEvents: .ValueChanged)
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "prepareProfile", name: "profileUpdated", object: nil)
      if !stacked {
        initializeSidebar()
        configureMenuSwipes()
        configureNavBar()
      }
      
      if stackedFromRoot {
        self.navigationController?.navigationBarHidden = false
      }
      
    }
  
  override func viewDidAppear(animated: Bool) {
    self.navigationController?.navigationBarHidden = false
    configureMenuSwipes()
  }
  
  override func viewWillDisappear(animated: Bool) {
    if stackedFromRoot {
      self.navigationController?.navigationBarHidden = true
    }
  }
  
  func dismissSelf() {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func setForStackedView() {
//    self.navigationController?.navigationBarHidden = false
//    print("self.navigationContrlller: \(self.navigationController)")
//    let backButton = UIBarButtonItem(barButtonSystemItem: .PageCurl, target: self, action: "dismissSelf")
//    self.navigationItem.leftBarButtonItem = backButton
    stacked = true
//    let navBar = UINavigationBar(frame: CGRectMake(0,0,self.view.frame.width, 64.0))
//    let backItem = UIBarButtonItem(barButtonSystemItem: .PageCurl, target: self, action: "dismissSelf")
//    self.view.addSubview(navBar)
  }
  
  func updatedAvatar() {
    self.avatarImageView.image = CurrentUser.info.model?.avatarImage
  }
  
  func setupForUser(user: User) {
    do {
      if let activities = user.activeActivities {
        self.currentActivity = try activities.lookup(UInt(0))
      }
    }
    catch {
      self.currentActivity = nil
      //hide the tree until the current activity gets set
      self.treeController?.toggleActive(false)
    }
    self.setupUserProfile(user)
    self.treeController?.fetchTreeData()
  }
  
  func reinitializeTreeController() {
    treeController?.fetchTreeData()
  }
  
  func setupUserProfile(user: User) {
      print("Setting Up User Profile")
      if let username = user.username {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          if let name = user.name {
            self.nameLabel.text = name
          }
          self.usernameLabel.text = username
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
  

  func prepareProfile() {
    if let user = viewing {
      setupForUser(user)
    } else {
      self.store = CurrentUser.info.store
      CurrentUser.info.fetchProfile(){ (success) in
        if success {
          if let user = CurrentUser.info.model {
            self.setupForUser(user)
          }
        }
      }
    }
  }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      if segue.identifier == "treeViewEmbed" {
        if let topNav = segue.destinationViewController as? UINavigationController, vc = topNav.topViewController as? TreeViewController {
          prepareProfile()
          vc.profileDelegate = self
          self.treeController = vc
          vc.viewing = self.viewing
          vc.store = store
          vc.fetchTreeData()
          if isShowingForGallery {
            self.profileModeSelector.selectedSegmentIndex = 1
            vc.showGallery(viewing)
          }
//          if let activity = currentActivity {
//            vc.setCurrentActivityTree(activity)
//          }
        }
      }
      
      if segue.identifier == "leafDrilldown" {
 //       if let nav = segue.destinationViewController as? UINavigationController, vc = nav.topViewController as? LeafDetailViewController {
        if let vc = segue.destinationViewController as? LeafDetailViewController {
          vc.viewing = self.viewing
          vc.profileDelegate = self
          self.drilldownController = vc
          if let recs = globalMainContainer?.gestureRecognizers {
            for rec in recs {
              globalMainContainer?.removeGestureRecognizer(rec)
            }
          }
        }
      }
      
      if segue.identifier == "showMediaFromGallery" {
        if let vc = segue.destinationViewController as? CommentsTableViewController, gallery = self.galleryController, media = gallery.selectedMediaObject {
          vc.media = media
          vc.viewing = self.viewing
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
    self.cancelButton.hidden = false
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
    if !checkForNewLeaves() {
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
    } else {
      alertShow(self, alertText: "Unable To Save Tree", alertMessage: "Please add ability names to any new abilities")
    }
  }
  
  func checkForNewLeaves() -> Bool {
    var brandNewFound = false
    if let leaves = store.treeStore.currentLeaves {
      for leaf in leaves {
        if leaf.changeStatus == .BrandNew {
          brandNewFound = true
        }
      }
    }
    return brandNewFound
  }
  
  @IBAction func activitySelectButtonPressed(sender: AnyObject) {
    //show activity popover
    self.performSegueWithIdentifier("activitySelectionPopoverSegue", sender: self)
  }
  
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    store.treeStore.resetStore()
    treeController?.fetchTreeData()
    self.changesPresent = false
    self.cancelButton.hidden = true
    self.saveButton.hidden = true
  }
  
  func dismissDrilldownModal() {
    self.drilldownController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func profileModeChanged(sender: UISegmentedControl) {
    let index = sender.selectedSegmentIndex
    if index == 0 {
      self.treeController?.navigationController?.popToRootViewControllerAnimated(false)
    } else {
      self.treeController?.showGallery(viewing)
    }
  }
  
  func showMediaFromGallery(vc: GalleryCollectionViewController) {
    self.galleryController = vc
    self.performSegueWithIdentifier("showMediaFromGallery", sender: self)
  }
}
