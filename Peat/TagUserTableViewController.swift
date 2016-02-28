//
//  TagUserTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

protocol TagUserDelegate {
  func getStore() -> PeatContentStore
}

protocol MediaTagUserDelegate {
  func userAdded(user: User)
}

class TagUserTableViewController: UITableViewController, UITextFieldDelegate {
  
  var textField: UITextField?
  var user: User?
  
  var delegate: TagUserDelegate?
  var mediaTagDelegate: MediaTagUserDelegate?
  
  var foundUsers: Array<User>?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()

    }
  
  func configureTextField() {
    let textField = UITextField(frame: CGRectMake(0,0,self.view.frame.width, 40))
    textField.delegate = self
    
    textField.backgroundColor = UIColor.whiteColor()
    textField.placeholder = "Search"
    textField.returnKeyType = .Done
    textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    self.textField = textField
    self.tableView.tableHeaderView = textField
  }
  
  func showSearchResults() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func textFieldDidChange(textField: UITextField) {
    if let text = textField.text {
      if let user = user {
        if text != "" {
          PeatSocialMediator.sharedMediator.searchUsers(text){ (foundUsers) in
            if let users = foundUsers {
              self.foundUsers?.removeAll()
              self.foundUsers = Array()
              for user in users {
                self.foundUsers!.append(User.userFromProfile(user))
              }
              self.showSearchResults()
            }
          }
        }
      }
    }
  }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return self.foundUsers != nil ? self.foundUsers!.count : 0
    }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 56
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("tagUserCell", forIndexPath: indexPath) as! TagUserTableViewCell
    if self.foundUsers?.count > 0 {
      if let user = self.foundUsers?[indexPath.row] {
        cell.configureWithUser(user)
        return cell
      }
    } else {
      cell.usernameLabel.text = "No Users Found"
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let users = self.foundUsers {
      do {
        let selectedUser = try users.lookup(UInt(indexPath.row))
        self.mediaTagDelegate?.userAdded(selectedUser)
        print("User added")
        self.dismissViewControllerAnimated(true, completion: nil)
      }
      catch {
        print("User not found")
      }
    }
  }

}
