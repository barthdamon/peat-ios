//
//  TagUserTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

@objc protocol MediaTagUserDelegate {
  func userAdded(user: User)
  func showUserProfile(user: User)
}

class TagUserTableViewController: UITableViewController, UITextFieldDelegate {
  
  var textField: UITextField?
  var user: User?
  
  var mediaTagDelegate: MediaTagUserDelegate?
  
  var foundUsers: Array<User>?
  var taggedUsers: Array<User>?
  
  var users: Array<User> {
    var all: Array<User> = []
    if let foundUsers = foundUsers {
      for found in foundUsers {
        all.append(found)
      }
    }
    if let taggedUsers = taggedUsers {
      for tagged in taggedUsers {
        all.append(tagged)
      }
    }
    return all
  }
  var cells: Array<TagUserTableViewCell> = []
  
  var media: MediaObject?
  
  var taggingEnabled = false
  var userForProfile: User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if media?.uploaderUser?._id == CurrentUser.info.model?._id {
      self.taggingEnabled = true
      configureTextField()
    }
    self.taggedUsers = media?.taggedUsers
    self.navigationController?.navigationBarHidden = false
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
    self.cells.removeAll()
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func textFieldDidChange(textField: UITextField) {
    if let text = textField.text {
      if text != "" {
        PeatSocialMediator.sharedMediator.searchUsers(text){ (newFoundUsers) in
          if let users = newFoundUsers {
            self.foundUsers?.removeAll()
            self.foundUsers = Array()
            for user in users {
              self.foundUsers!.append(User.userFromProfile(user))
            }
            self.showSearchResults()
          }
        }
      } else {
        self.foundUsers = nil
        self.showSearchResults()
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
    return users.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 56
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("tagUserCell", forIndexPath: indexPath) as! TagUserTableViewCell
    if users.count > 0 {
      do {
        let user = try users.lookup(UInt(indexPath.row))
        cell.configureWithUser(user)
        if let tagged = taggedUsers where tagged.contains(user) {
          cell.setTagged()
        }
        cells.append(cell)
        return cell
      }
      catch {
        cell.usernameLabel.text = "No Users Found"
      }
    } else {
      cell.usernameLabel.text = "No Users Found"
    }
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    do {
      let selectedUser = try users.lookup(UInt(indexPath.row))
      let selectedCell = try cells.lookup(UInt(indexPath.row))
      if taggingEnabled {
        if let delegate = mediaTagDelegate where !userIsTagged(selectedUser) {
          delegate.userAdded(selectedUser)
          selectedCell.setTagged()
          print("User added")
//          self.dismissViewControllerAnimated(true, completion: nil)
        }
      } else {
        userForProfile = selectedUser
        self.performSegueWithIdentifier("showProfileForUser", sender: self)
//            mediaTagDelegate?.showUserProfile(selectedUser)
          //perform segue showing the profile of the person tagged....
      }
    }
    catch {
      print("User not found")
    }
  }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showProfileForUser" {
      if let vc = segue.destinationViewController as? ProfileViewController {
        vc.viewing = self.userForProfile
        vc.setForStackedView()
      }
    }
    
    if segue.identifier == "showGalleryForUser" {
      if let vc = segue.destinationViewController as? GalleryCollectionViewController {
        vc.viewing = self.userForProfile
        vc.setForStackedView()
      }
    }
  }
  
  func userIsTagged(user: User) -> Bool {
    var isTagged = false
    if let tagged = taggedUsers {
      for taggedUser in tagged {
        if taggedUser._id == user._id {
          isTagged = true
        }
      }
    }
    return isTagged
  }
  
}
