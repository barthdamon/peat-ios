//
//  FriendsTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, UITextFieldDelegate, ViewControllerWithMenu {
  
  enum FriendMode {
    case Search
    case List
  }
  
  var foundUsers: Array<User>?
  var friends: Array<User>?
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
      PeatSocialMediator.sharedMediator.initializeFriendsList()
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "prepareFriendsList", name: "loadingFriendsComplete", object: nil)
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
          cell.usernameLabel.text = friend.username
          cell.nameLabel.text = friend.name
          cell.friend = friend
        } else {
          cell.usernameLabel.text = "No Friends Found"
        }
        return cell
      case .Search:
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! UserSearchResultTableViewCell
        if self.foundUsers?.count > 0 {
          if let user = self.foundUsers?[indexPath.row] {
            cell.usernameLabel.text = user.username
            cell.nameLabel.text = user.name
            cell.foundUser = user
            if user.isFriend {
              cell.addButton.hidden = true
              cell.usernameLabel.textColor = UIColor.grayColor()
              cell.nameLabel.textColor = UIColor.grayColor()
            }
          }
        } else {
          cell.usernameLabel.text = "No Users Found"
          cell.nameLabel.text = ""
        }
        return cell
      }

    }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch mode {
    case .List:
      if let friend = self.friends {
        //Perform the profile view segue with the friend
        print(friend)
        break
      }
    case .Search:
      //Perform the profile view segue with the foundUser
      break
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func prepareFriendsList() {
    friends = PeatSocialMediator.sharedMediator.friends
    self.tableView.reloadData()
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
        PeatSocialMediator.sharedMediator.searchUsers(text)
      } else {
        exitSearch()
      }
    }
  }
  
  func showSearchResults() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.mode = .Search
      self.foundUsers = nil
      self.foundUsers = PeatSocialMediator.sharedMediator.userSearchResults
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


}
