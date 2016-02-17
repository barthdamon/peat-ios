//
//  SearchTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/15/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UITextFieldDelegate {
  
  var textField: UITextField?
  var leafDetailVC: LeafDetailViewController?
  
  var matchingAbilities: Array<Ability>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      
      configureTextField()
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
    //for when you want to gray out activities that already exist
//    let user = leafDetailVC?.mode == .Edit ? CurrentUser.info.model : leafDetailVC?.viewing
//    if let user = user {
    if let text = textField.text, vc = leafDetailVC, delegate = vc.profileDelegate, activity = delegate.currentActivity, name = activity.name {
      if text != "" {
        vc.profileDelegate?.store.searchForAbilities(name, abilityTerm: text, callback: { (abilities) -> () in
          if let abilities = abilities {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              self.matchingAbilities = abilities
              self.tableView.reloadData()
            })
          }
        })
      }
    }
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let text = textField.text where text != "" {
      var foundMatch = false
      if let abilities = matchingAbilities {
        for ability in abilities {
          if text == ability.name {
            leafDetailVC?.selectedAbility = ability
            foundMatch = true
          }
        }
      }
      if !foundMatch {
        let newAbility = Ability()
        newAbility.name = text
        leafDetailVC?.selectedAbility = newAbility
      }
    }
    self.dismissViewControllerAnimated(true, completion: nil)
    return true
  }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return matchingAbilities != nil ? matchingAbilities!.count : 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("abilityCell", forIndexPath: indexPath)
      if let abilities = self.matchingAbilities {
        let ability = abilities[indexPath.row]
        cell.textLabel?.text = ability.name
      }
      return cell
    }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let abilities = self.matchingAbilities {
      let selectedAbility = abilities[indexPath.row]
      self.leafDetailVC?.selectedAbility = selectedAbility
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
