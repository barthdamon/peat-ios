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
  
  @IBOutlet weak var titleSaveButton: UIButton!
  @IBOutlet weak var uploadLabel: UILabel!
  @IBOutlet weak var witnessLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    if let leaf = leaf {
      leaf.fetchContents(){ (success) ->() in
        guard success else {
          print("Error fetching leaf contents")
          return
        }
        self.configureTitleView()
        self.containerTableView?.reloadData()
      }
    }
  }
  
  func configureTitleView() {
    if let leaf = self.leaf {
      self.leafTitleLabel.text = leaf.title
      self.titleEditField.text = leaf.title
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "leafDetailEmbed" {
      if let vc = segue.destinationViewController as? LeafDetailTableViewController {
        self.containerTableView = vc.tableView
      }
    }
  }
  
  func setValuesOnLeaf() {
    //actually save the values of all of the fields now....
    self.leaf?.title = self.leafTitleLabel.text
    self.leaf?.save(){ (success) in
      if success {
        self.editButton.setTitle("Edit", forState: UIControlState.Normal)
        alertShow(self, alertText: "Success", alertMessage: "Leaf saved sucessfully")
      }
    }
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
    self.leaf?.title = self.titleEditField.text
    self.leafTitleLabel.text = self.titleEditField.text
    self.titleEditField.hidden = true
    self.titleSaveButton.hidden = true
    self.leafTitleLabel.hidden = false
  }
  
  @IBAction func uploadButtonPressed(sender: AnyObject) {
    //open up the ol camera role.....
    self.performSegueWithIdentifier("showUploadOptions", sender: self)
    //also pause any media playing here, might already work
  }
  
  @IBAction func returnButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true) { () -> Void in
    }
  }
  
 }
