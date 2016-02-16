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

class LeafDetailViewController: UIViewController, UIPopoverPresentationControllerDelegate {
  @IBOutlet weak var titleView: UIView!
  @IBOutlet weak var saveButton: UIButton!
  
  @IBOutlet weak var completionStatusControl: UISegmentedControl!
  @IBOutlet weak var leafTitleLabel: UILabel!
  @IBOutlet weak var returnButton: UIButton!
  var leaf: Leaf? {
    return profileDelegate?.store.treeStore.selectedLeaf
  }
  var containerTableView: UITableView?
  
  var mode: LeafMode = .Edit
  
  var viewing: User?
  
  var selectedAbility: Ability? {
    didSet{
      if let name = selectedAbility?.name {
        self.leafTitleLabel.text = name
      }
    }
  }
  
  
  @IBOutlet weak var abilityNameEditButton: UIButton!
  @IBOutlet weak var uploadLabel: UILabel!
  @IBOutlet weak var witnessLabel: UILabel!
  @IBOutlet weak var uploadButton: UIButton!
  
  var profileDelegate: ProfileViewController?
  
  var selectedMediaForComments: MediaObject?
  var tableViewVC: LeafDetailTableViewController?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
        self.containerTableView?.reloadData()
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
      self.completionStatusControl.userInteractionEnabled = false
    case .Edit:
      self.completionStatusControl.userInteractionEnabled = false
      break
    }
  }
  
  func newMediaAdded() {
    toggleSaveOption(true)
    self.leaf?.getCompletionStatus()
    self.setSelectedCompletion()
    self.tableViewVC?.newMediaAdded()
  }

  func setSelectedCompletion() {
    var index = 2
    if let status = leaf?.completionStatus {
      switch status {
      case .Completed:
        index = 0
      case .Goal:
        index = 2
      case .Learning:
        index = 1
      }
    }
    self.completionStatusControl.selectedSegmentIndex = index
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
      }
    }
    if segue.identifier == "showUploadOptions" {
      if let vc = segue.destinationViewController as? MediaUploadViewController {
        vc.leafDetailDelegate = self
      }
    }
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  func saveLeaf() {
    self.leaf?.save(){ (success) in
      self.saveButton.enabled = false
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if success {
          self.saveButton.hidden = true
//          alertShow(self, alertText: "Success", alertMessage: "Leaf saved sucessfully")
        } else {
          self.saveButton.enabled = true
//          alertShow(self, alertText: "Error", alertMessage: "Leaf save unsuccessful")
        }
      })
    }
  }
  
  func setValuesOnLeaf() {
    //actually save the values of all of the fields now....
//    self.leaf?.ability?.abilityName = self.leafTitleLabel.text
    self.leaf?.ability = selectedAbility
    saveButton.enabled = false
    setValuesOnLeaf()
    saveLeaf()
  }
  
  @IBAction func saveButtonPressed(sender: AnyObject) {
    toggleSaveOption(false)
  }
  
  func toggleSaveOption(forUpload: Bool) {
    if saveButton.hidden == false && saveButton.enabled == true {
      saveButton.enabled = false
      setValuesOnLeaf()
    } else {
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
      self.performSegueWithIdentifier("showUploadOptions", sender: self)
      //also pause any media playing here, might already work
    case .View:
      //show popover with option to submit witness requestmain
//      self.performSegueWithIdentifier("witnessPopover", sender: self)
      sendWitness()
      break
    }

  }
  
  func showCommentsForMedia(media: MediaObject) {
    self.selectedMediaForComments = media
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
    if let leaf = leaf, medias = leaf.media {
      for media in medias {
        if media.needsPublishing {
          needsSaving = true
        }
      }
    }
    //TODO: check if there are new mediaObjects. of if there are unsaved changes. if there are prompt a warning...
    if !needsSaving && !self.saveButton.hidden && !self.saveButton.enabled {
      dismissSelf()
    } else {
      saveAlertShow(self, alertText: "Warning", alertMessage: "You have unsaved changes")
    }
  }
  
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
  
  func saveAlertShow(vc: UIViewController, alertText :String, alertMessage :String) {
    let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
    }))
    
    alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
      alert.dismissViewControllerAnimated(true, completion: nil)
      self.toggleSaveOption(false)
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
