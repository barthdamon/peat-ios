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

class LeafDetailViewController: UIViewController {
  @IBOutlet weak var titleView: UIView!
  @IBOutlet weak var titleEditField: UITextField!
  @IBOutlet weak var editButton: UIButton!
  
  @IBOutlet weak var completionStatusControl: UISegmentedControl!
  @IBOutlet weak var leafTitleLabel: UILabel!
  @IBOutlet weak var returnButton: UIButton!
  var leaf: Leaf? {
    return PeatContentStore.sharedStore.treeStore.selectedLeaf
  }
  var containerTableView: UITableView?
  
  var mode: LeafMode = .Edit
  
  var viewing: User?
  
  @IBOutlet weak var titleSaveButton: UIButton!
  @IBOutlet weak var uploadLabel: UILabel!
  @IBOutlet weak var witnessLabel: UILabel!
  @IBOutlet weak var uploadButton: UIButton!
  
  var profileDelegate: ProfileViewController?
  
  var selectedMediaForComments: MediaObject?
  
  
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "newMediaAdded", name: "newMediaPostSuccessful", object: nil)
    
    switch mode {
    case .View:
      self.uploadButton.setTitle("Witness", forState: .Normal)
      self.editButton.hidden = true
      self.editButton.enabled = false
      self.completionStatusControl.userInteractionEnabled = false
    case .Edit:
      break
    }
  }
  
  
  func configureTitleView() {
    if let leaf = self.leaf {
      self.leafTitleLabel.text = leaf.title
      self.titleEditField.text = leaf.title
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
      }
    }
  }
  
  func newMediaAdded() {
    setValuesOnLeaf()
    saveLeaf()
  }
  
  func saveLeaf() {
    self.leaf?.save(){ (success) in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if success {
          self.editButton.setTitle("Edit", forState: UIControlState.Normal)
//          alertShow(self, alertText: "Success", alertMessage: "Leaf saved sucessfully")
        } else {
          self.editButton.setTitle("Edit", forState: UIControlState.Normal)
//          alertShow(self, alertText: "Error", alertMessage: "Leaf save unsuccessful")
        }
      })
    }
  }
  
  func setValuesOnLeaf() {
    //actually save the values of all of the fields now....
    self.leaf?.title = self.leafTitleLabel.text
    saveLeaf()
  }
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    if editButton.titleLabel?.text == "Save" {
      setValuesOnLeaf()
    } else {
      self.editButton.setTitle("Save", forState: UIControlState.Normal)
      self.leafTitleLabel.hidden = true
      self.titleEditField.hidden = false
      self.titleSaveButton.hidden = false
    }
  }
  
  @IBAction func textFieldEditDone(sender: AnyObject) {
    titleEditField.resignFirstResponder()
    self.leafTitleLabel.text = self.titleEditField.text
    self.titleEditField.hidden = true
    self.titleSaveButton.hidden = true
    self.leafTitleLabel.hidden = false
  }
  
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

  
  @IBAction func returnButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
 }
