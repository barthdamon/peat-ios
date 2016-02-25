////
////  LeafDetailViewController.swift
////  Peat
////
////  Created by Matthew Barth on 11/5/15.
////  Copyright © 2015 Matthew Barth. All rights reserved.
////
//
import Foundation
import UIKit

enum LeafMode {
  case Edit
  case View
}

class LeafDetailViewController: UIViewController, UIPopoverPresentationControllerDelegate, CommentDetailDelegate, MediaUploadDelegate {
  @IBOutlet weak var titleView: UIView!
  @IBOutlet weak var saveButton: UIButton!
  
  @IBOutlet weak var completionStatusLabel: UILabel!

  @IBOutlet weak var leafTitleLabel: UILabel!
  @IBOutlet weak var returnButton: UIButton!
  var leaf: Leaf? {
    return profileDelegate?.store.treeStore.selectedLeaf
  }
  var containerTableView: UITableView?
  
  var mode: LeafMode = .Edit
  
  var viewing: User?
  
  var selectedAbility: Ability?
  
  @IBOutlet weak var feedSelectionPicker: UISegmentedControl!

  
  @IBOutlet weak var abilityNameEditButton: UIButton!
  @IBOutlet weak var uploadLabel: UILabel!
  @IBOutlet weak var witnessLabel: UILabel!
  @IBOutlet weak var uploadButton: UIButton!
  
  var profileDelegate: ProfileViewController?
  
  var selectedMediaForComments: MediaObject?
  var selectedHeaderViewForComments: MediaCellHeaderView?
  var tableViewVC: LeafDetailTableViewController?
  var uploadFromGallery = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.feedSelectionPicker.addTarget(self, action: "feedSelectionChanged:", forControlEvents: .ValueChanged)
    if let _ = self.viewing {
      mode = .View
    }
    if let leaf = leaf {
      leaf.fetchContents(){ (success) ->() in
        guard success else {
          print("Error fetching leaf contents")
          return
        }
        self.configureTitleView()
        self.tableViewVC?.setMode()
        if let witnesses = leaf.witnesses where self.mode == .View {
          for witness in witnesses {
            if witness.witness_Id == CurrentUser.info.model?._id {
              self.uploadButton.enabled = false
            }
          }
        }
      }
    }
    
    switch mode {
    case .View:
      self.uploadButton.setTitle("Witness", forState: .Normal)
      self.abilityNameEditButton.hidden = true
      self.abilityNameEditButton.enabled = false
    case .Edit:
      break
    }
  }
  
  func getStore() -> PeatContentStore? {
    return profileDelegate?.store
  }
  
  func selectedAbility(ability: Ability) {
    //check to make sure ability isn't already on the tree
    if let name = ability.name {
      var exists = false
      if let leaves = profileDelegate?.store.treeStore.currentLeaves {
        leaves.forEach({ (leaf) -> () in
          if let leafAbilityName = leaf.ability?.name {
            if leafAbilityName == name {
              exists = true
            }
          }
        })
      }
      if !exists {
        self.selectedAbility = ability
        self.leafTitleLabel.text = name
      } else {
        alertShow(self, alertText: "Duplicate Ability", alertMessage: "Please select another ability")
      }
    }
  }
  
  func newMediaAdded() {
    toggleSaveOption(true)
    self.leaf?.getCompletionStatus()
    self.setSelectedCompletion()
    self.tableViewVC?.setMode()
//    self.tableViewVC?.newMediaAdded()
  }

  func setSelectedCompletion() {
    if let status = leaf?.completionStatus {
      self.completionStatusLabel.text = status.rawValue
    }
  }
  
  func configureTitleView() {
    if let leaf = self.leaf {
      self.setSelectedCompletion()
      self.leafTitleLabel.text = leaf.ability?.name
      if let witnesses = leaf.witnesses {
        let witnessCount = witnesses.count
        let lingo = witnessCount == 1 ? "Witness" : "Witnesses"
        self.witnessLabel.text = "\(witnessCount) \(lingo)"
      }
      var mediaCount = 0
      if let media = leaf.media {
        mediaCount = media.count
      }
      let lingo = mediaCount == 1 ? "Upload" : "Uploads"
      self.uploadLabel.text = "\(mediaCount) \(lingo)"
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "leafDetailEmbed" {
      if let vc = segue.destinationViewController as? LeafDetailTableViewController {
        self.containerTableView = vc.tableView
        vc.viewing = viewing
        vc.detailVC = self
        self.tableViewVC = vc
      }
    }
    
    if segue.identifier == "abilitySearchSegue" {
      if let vc = segue.destinationViewController as? SearchTableViewController {
        let popover = vc.popoverPresentationController
        popover?.delegate = self
        vc.popoverPresentationController?.delegate = self
//        vc.popoverPresentationController?.sourceView = self.view
//        vc.popoverPresentationController?.sourceRect = CGRectMake(100,100,0,0)
        vc.preferredContentSize = CGSize(width: self.view.frame.width, height: 200)
        vc.leafDetailVC = self
      }
    }
    
    if segue.identifier == "witnessPopover" {
      if let vc = segue.destinationViewController as? WitnessRequestViewController {
        vc.leaf = self.leaf
        vc.viewing = self.viewing
      }
    }
    
    if segue.identifier == "showComments" {
      if let vc = segue.destinationViewController as? CommentsTableViewController {
        vc.media = selectedMediaForComments
        vc.viewing = viewing
        vc.delegate = self
        vc.headerView = self.selectedHeaderViewForComments
      }
    }
    if segue.identifier == "showUploadOptions" {
      if let vc = segue.destinationViewController as? MediaUploadViewController {
        vc.delegate = self
        if uploadFromGallery {
          vc.uploadFromGallery = true
          vc.displayGalleryOptions()
        } else {
          vc.uploadFromGallery = false
          vc.displayCameraControl()
        }
      }
    }
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  func saveLeaf() {
    self.saveButton.enabled = false
    self.leaf?.save(){ (success) in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if success {
          NSNotificationCenter.defaultCenter().postNotificationName("leafMediaPublished", object: self, userInfo: nil)
          self.toggleSaveOption(false)
//          alertShow(self, alertText: "Success", alertMessage: "Leaf saved sucessfully")
        } else {
          alertShow(self, alertText: "Error Saving Leaf", alertMessage: "Okay")
          self.toggleSaveOption(true)
//          alertShow(self, alertText: "Error", alertMessage: "Leaf save unsuccessful")
        }
      })
    }
  }
  
  func setValuesOnLeaf() {
    if let leaf = self.leaf {
      if let ability = selectedAbility {
        leaf.setAbilityOnLeaf(ability)
      }
      leaf.changed(.Updated)
      if leaf.ability != nil {
        saveLeaf()
      } else {
        alertShow(self, alertText: "Unable to Save", alertMessage: "Please add Ability Title")
      }
    }
  }
  
  @IBAction func saveButtonPressed(sender: AnyObject) {
    setValuesOnLeaf()
  }
  
  func toggleSaveOption(needsSave: Bool) {
    if saveButton.hidden == false && !needsSave {
      saveButton.enabled = false
      saveButton.hidden = true
    } else  {
      saveButton.hidden = false
      saveButton.enabled = true
    }
  }
  
  
  @IBAction func abilityNameEditButtonPressed(sender: AnyObject) {
    self.performSegueWithIdentifier("abilitySearchSegue", sender: self)
  }
  
//  @IBAction func textFieldEditDone(sender: AnyObject) {
//    titleEditField.resignFirstResponder()
//    self.leafTitleLabel.text = self.titleEditField.text
//    self.titleEditField.hidden = true
//    self.titleSaveButton.hidden = true
//    self.leafTitleLabel.hidden = false
//  }
  
  @IBAction func uploadButtonPressed(sender: AnyObject) {
    //open up the ol camera role.....
    switch mode {
    case .Edit:
      self.uploadOptionsShow(self, alertText: "Upload Options", alertMessage: "Select from the following upload options:")
//      self.performSegueWithIdentifier("showUploadOptions", sender: self)
      //also pause any media playing here, might already work
    case .View:
      //show popover with option to submit witness requestmain
//      self.performSegueWithIdentifier("witnessPopover", sender: self)
      sendWitness()
      break
    }

  }
  
  func showCommentsForMedia(media: MediaObject, headerView: MediaCellHeaderView) {
//    func commentsButtonPressed(media: MediaObject?) {
//      if let media = media {
//        self.selectedHeaderViewForComments = createHeaderForMedia(media)
//        self.performSegueWithIdentifier("showComments", sender: self)
//      }
//    }
    self.selectedMediaForComments = media
    self.selectedHeaderViewForComments = headerView
    self.performSegueWithIdentifier("showComments", sender: self)
  }
  
  func showLikesForMedia(media: MediaObject) {
    self.selectedMediaForComments = media
    self.performSegueWithIdentifier("showLikes", sender: self)
  }
  
  func sendWitness() {
    let params = [
      "leafId" : paramFor(leaf?.leafId),
      "witnessId" : paramFor(CurrentUser.info.model?._id),
      "witnessed_Id" : paramFor(viewing?._id),
    ]
    PeatSocialMediator.sharedMediator.sendWitnessRequest(params) { (success) -> () in
      if success {
        print("SUCCESS, show something")
      } else {
        print("FAILURE, still show something")
      }
    }
  }

  func updateCommentCount() {
    self.tableViewVC?.updateCommentCount()
  }
  
  func dismissSelf() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func removeUnsavedChanges() {
    //TODO: remove any unpublished media items or unsaved changes from the leaf
    if let leaf = self.leaf, leafMedias = leaf.media {
      for media in leafMedias {
        if media.needsPublishing {
          profileDelegate?.store.treeStore.currentMediaObjects?.remove(media)
        }
      }
    }
  }
  

  
  @IBAction func returnButtonPressed(sender: AnyObject) {
    var needsSaving = false
    if let leaf = leaf {
      if leaf.changeStatus != .Unchanged {
        needsSaving = true
      }
      if leaf.ability == nil || leaf.ability?.name == nil {
        needsSaving = true
      }
      if let medias = leaf.media {
        for media in medias {
          if media.needsPublishing {
            needsSaving = true
          }
        }
      }
    }
    //TODO: check if there are new mediaObjects. of if there are unsaved changes. if there are prompt a warning...
    if !needsSaving {
      dismissSelf()
    } else {
      saveAlertShow(self, alertText: "Warning", alertMessage: "You have unsaved changes")
    }
  }
  
  func modeSet(mode: LeafFeedMode) {
    if mode == .Uploads {
      self.feedSelectionPicker.selectedSegmentIndex = 0
    } else {
      self.feedSelectionPicker.selectedSegmentIndex = 1
    }
  }
  
  func setMode(mode: LeafFeedMode) {
    self.tableViewVC?.mode = mode
    self.tableViewVC?.getLeafFeed()
    self.tableViewVC?.tableView.reloadData()
  }
  
  
  func feedSelectionChanged(sender: UISegmentedControl) {
    let index = sender.selectedSegmentIndex
    if index == 0 { setMode(.Uploads) } else if index == 1 { setMode(.Feed) } else if index == 2 { setMode(.Tutorials) }
  }
  
  
  //MARK: Helpers
  func missingTitleAlertShow(vc: UIViewController, alertText :String, alertMessage :String) {
    let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "Don't Save", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
      self.removeUnsavedChanges()
      self.dismissSelf()
    }))
    
    alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
    }))
    
    //can add another action (maybe cancel, here)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      vc.presentViewController(alert, animated: true, completion: nil)
    })
  }
  
  func uploadOptionsShow(vc: UIViewController, alertText :String, alertMessage :String) {
    let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "Upload From Device", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
      self.uploadFromGallery = false
      self.performSegueWithIdentifier("showUploadOptions", sender: self)
    }))
    
    alert.addAction(UIAlertAction(title: "Upload From Gallery", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
      self.uploadFromGallery = true
      self.performSegueWithIdentifier("showUploadOptions", sender: self)
    }))
    
    //can add another action (maybe cancel, here)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      vc.presentViewController(alert, animated: true, completion: nil)
    })
  }
  
  func saveAlertShow(vc: UIViewController, alertText :String, alertMessage :String) {
    let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
    }))
    
    alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
      self.setValuesOnLeaf()
      self.dismissSelf()
    }))
    
    alert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
      self.removeUnsavedChanges()
      self.dismissSelf()
    }))
    //can add another action (maybe cancel, here)
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      vc.presentViewController(alert, animated: true, completion: nil)
    })
  }

  
 }