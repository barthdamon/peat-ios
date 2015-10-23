//
//  FriendsTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 10/15/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController, UITextFieldDelegate {
  
  enum FriendMode {
    case Search
    case List
  }
  
  var foundUsers: Array<User>?
  var friends: Array<User>?
  var searchField: UITextField?
  var mode: FriendMode = .List

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      configureNavBar()
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
      return friends != nil ? friends!.count : 1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      switch mode {
      case .List:
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell
        if let friend = self.friends?[indexPath.row] {
          cell.usernameLabel.text = friend.username
          cell.nameLabel.text = friend.name
        } else {
          cell.usernameLabel.text = "No Friends Found"
        }
        return cell
      case .Search:
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! UserSearchResultTableViewCell
        if let user = self.foundUsers?[indexPath.row] {
          cell.usernameLabel.text = user.username
          cell.nameLabel.text = user.name
        }
        return cell
      }

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
  
  func configureNavBar() {
    let width = self.view.frame.width  * 0.7
    searchField = UITextField(frame: CGRectMake(0, 0, width, 30))
    if let searchField = searchField {
      searchField.backgroundColor = UIColor.whiteColor()
      searchField.placeholder = "Search"
      searchField.returnKeyType = .Search
      searchField.delegate = self
      searchField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
      
      configureTextFieldElements(searchField)
      
      let searchItem = UIBarButtonItem(customView: searchField)
      self.navigationItem.leftBarButtonItem = searchItem
    }
    
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "exitSearch")
    self.navigationItem.rightBarButtonItem = cancelButton
  }
  
  func configureTextFieldElements(textField: UITextField) {
    
    let iconSize: CGFloat = 18
    
    let container = UIView(frame: CGRectMake(4, 0, 28, 18))
    let magnifyView = UIImageView(frame: CGRectMake(0, 0, iconSize, iconSize))
    magnifyView.image = UIImage(named: "magnify")
    magnifyView.image = magnifyView.image!.imageWithRenderingMode(.AlwaysTemplate)
    magnifyView.tintColor = .lightGrayColor()
    
    container.addSubview(magnifyView)
    magnifyView.center.x += 4
    //    magnifyView.center.y -= 4
    
    textField.leftView = container
    
    textField.leftViewMode = .Always
  }
  
  func textFieldDidChange(textField: UITextField) {
    print("NEW SEARCH LETTER ENTERED")
    if let text = textField.text {
      PeatSocialMediator.sharedMediator.searchUsers(text)
    }
  }
  
  func showSearchResults() {
    mode = .Search
    foundUsers = nil
    foundUsers = PeatSocialMediator.sharedMediator.userSearchResults
    tableView.reloadData()
  }
  
  func exitSearch() {
    //reload table view with only current friends
    mode = .List
    tableView.reloadData()
  }


}
