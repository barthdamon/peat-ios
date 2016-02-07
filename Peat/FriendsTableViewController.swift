//
//  FriendsTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, UITextFieldDelegate, ViewControllerWithMenu, UIGestureRecognizerDelegate {
  
  enum FriendMode {
    case Search
    case List
  }
  
  var selectedUser: User?
  var foundUsers: Array<User>?
  var friends: Array<User>? {
    return CurrentUser.info.model?.friends
  }
  var searchField: UITextField?
  var mode: FriendMode = .List
  var sidebarClient: SideMenuClient?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      initializeSidebar()
      configureNavBar()
      configureMenuSwipes()
      configureSearchBar()
      
      CurrentUser.info.model?.initializeFriendsList({ (success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
          })
        } else {
          //show error
        }
      })
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "showProfileForUser:", name: "userSelected", object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "showSearchResults", name: "recievedSearchResults", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      switch mode {
      case .List:
        return friends != nil ? friends!.count : 1
      case .Search:
        return foundUsers != nil ? foundUsers!.count : 1
      }

    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      switch mode {
      case .List:
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell
        if let friend = self.friends?[indexPath.row] {
          if let username = friend.username, first = friend.first, last = friend.last {
            cell.usernameLabel.text = username
            cell.nameLabel.text = "\(first) \(last)"
            cell.friend = friend
//            friend.generateAvatarImage({ (image) -> () in
//              cell.avatarImageView.image = image
//            })
          }
        } else {
          cell.usernameLabel.text = "No Friends Found"
        }
        return cell
      case .Search:
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! UserSearchResultTableViewCell
        if self.foundUsers?.count > 0 {
          if let user = self.foundUsers?[indexPath.row] {
            if let username = user.username, first = user.first, last = user.last {
              cell.usernameLabel.text = username
              cell.nameLabel.text = "\(first) \(last)"
              cell.user = user
              if CurrentUser.info.isFriend(user) {
                cell.addButton.hidden = true
                cell.usernameLabel.textColor = UIColor.grayColor()
                cell.nameLabel.textColor = UIColor.grayColor()
              }
//              user.generateAvatarImage({ (image) -> () in
//                cell.avatarImageView.image = image
//              })
            }
          }
        } else {
          cell.usernameLabel.text = "No Users Found"
//          cell.nameLabel.text = ""
        }
        return cell
      }

    }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch mode {
    case .List:
      if let friends = self.friends {
        self.selectedUser = friends[indexPath.row]
        self.performSegueWithIdentifier("profileForUser", sender: self)
      }
    case .Search:
      if let users = self.foundUsers {
        self.selectedUser = users[indexPath.row]
        self.performSegueWithIdentifier("profileForUser", sender: self)
      }
    }
  }
  
  //MARK: Sidebar
  func showProfileForUser(notification: NSNotification) {
    if let userObject = notification.object as? User {
      self.selectedUser = userObject
      self.performSegueWithIdentifier("profileForUser", sender: self)
    }
  }
  
  func initializeSidebar() {
    self.sidebarClient = SideMenuClient(clientController: self, tabBar: self.tabBarController)
  }
  
  func configureNavBar() {
    sidebarClient?.configureNavBar()
  }
  
  func configureMenuSwipes() {
    sidebarClient?.configureMenuSwipes()
  }

  
  func configureSearchBar() {
    let width = self.view.frame.width  * 0.6
    searchField = UITextField(frame: CGRectMake(0, 0, width, 30))
    if let searchField = searchField {
      searchField.backgroundColor = UIColor.whiteColor()
      searchField.placeholder = "Search"
      searchField.returnKeyType = .Search
      searchField.delegate = self
      searchField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
      
      configureTextFieldElements(searchField)
      
      let searchItem = UIView(frame: CGRectMake(0,0, self.view.frame.width * 0.6, 40))
      searchItem.backgroundColor = .clearColor()
      searchItem.addSubview(searchField)
      self.navigationItem.titleView = searchItem
    }
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "exitSearch")
    self.navigationItem.rightBarButtonItem = cancelButton
  }
  
  
  
  func configureTextFieldElements(textField: UITextField) {
    
    let iconSize: CGFloat = 18
    //magnifyContainer
    let magnifyContainer = UIView(frame: CGRectMake(4, 0, 28, 18))
    let magnifyView = UIImageView(frame: CGRectMake(0, 0, iconSize, iconSize))
    magnifyView.image = UIImage(named: "magnify")
    magnifyView.image = magnifyView.image!.imageWithRenderingMode(.AlwaysTemplate)
    magnifyView.tintColor = .lightGrayColor()
    
    magnifyContainer.addSubview(magnifyView)
    magnifyView.center.x += 4
    textField.leftView = magnifyContainer
    
    //cancelContainer
//    let cancelContainer = UIView(frame: CGRectMake(-4, 0, 28, 18))
//    let cancelView = UIImageView(frame: CGRectMake(0, 0, iconSize, iconSize))
//    magnifyView.image = UIImage(named: "cancel.png")
//    magnifyView.image = magnifyView.image!.imageWithRenderingMode(.AlwaysTemplate)
//    magnifyView.tintColor = .lightGrayColor()
//    
//    cancelContainer.addSubview(cancelView)
//    magnifyView.center.x -= 4
//    textField.rightView = cancelContainer
    
    textField.leftViewMode = .Always
//    textField.rightViewMode = .Always
  }
  
  func textFieldDidChange(textField: UITextField) {
    print("NEW SEARCH LETTER ENTERED")
    if let text = textField.text {
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
      } else {
        exitSearch()
      }
    }
  }
  
  func showSearchResults() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.mode = .Search
      self.tableView.reloadData()
    })
  }
  
  func exitSearch() {
    //reload table view with only current friends
    mode = .List
    self.searchField?.text = ""
    self.searchField?.resignFirstResponder()
    tableView.reloadData()
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "profileForUser" {
      if let vc = segue.destinationViewController as? ProfileViewController {
        vc.viewing = self.selectedUser
      }
    }
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }


}
