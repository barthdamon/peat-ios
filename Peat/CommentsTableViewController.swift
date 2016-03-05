//
//  CommentsTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/7/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

@objc protocol CommentDetailDelegate {
  func updateCommentCount()
  optional func createHeaderForMedia(currentObject: MediaObject) -> MediaCellHeaderView?
}

class CommentsTableViewController: UITableViewController, MediaTagUserDelegate, MediaHeaderCellDelegate {
  
  var media: MediaObject?
  var viewing: User?
  
  var delegate: CommentDetailDelegate?
  var playerCell: MediaDrilldownTableViewCell?
  var headerView: MediaCellHeaderView?
  
  //headerCellDelegate vars:
  var taggedUsersForShow: Array<User>?
  var userForProfile: User?
  var isShowingForGallery: Bool = false
  var mediaForTagged: MediaObject?

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.tableView.estimatedRowHeight = 80
      self.tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return headerView
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      if let comments = media?.comments {
        return comments.count + 2
      } else {
        return 2
      }
    }
  
  //  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  //    if let media = media, comments = media.comments {
  //      if comments.count > 3 {
  //        return 5
  //      } else {
  //        return comments.count + 2
  //      }
  //    } else {
  //      return 2
  //    }
  //  }
  //
  //  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  //    return 1
  //  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showUserProfile" {
      if let vc = segue.destinationViewController as? ProfileViewController {
        vc.viewing = userForProfile
        vc.setForStackedView()
        vc.isShowingForGallery = isShowingForGallery
        isShowingForGallery = false
      }
    }
    
    if segue.identifier == "showTaggedSegue" {
      if let vc = segue.destinationViewController as? TagUserTableViewController {
        vc.mediaTagDelegate = self
        vc.user = CurrentUser.info.model
        vc.media = self.mediaForTagged
        //        let popover = vc.popoverPresentationController
        //        popover?.delegate = self
        //        vc.popoverPresentationController?.delegate = self
        //        //        vc.popoverPresentationController?.sourceView = self.view
        //        //        vc.popoverPresentationController?.sourceRect = CGRectMake(100,100,0,0)
        //        vc.preferredContentSize = CGSize(width: self.view.frame.width, height: 200)
      }
    }
  }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      var postIndex = 1
      if let comments = media?.comments {
        postIndex = comments.count + 1
      }
      switch indexPath.row {
      case 0:
        if let cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as? MediaDrilldownTableViewCell, media = media {
          cell.viewing = viewing
          cell.configureWithMedia(media)
          self.playerCell = cell
          return cell
        }
      case postIndex:
        if let cell = tableView.dequeueReusableCellWithIdentifier("postCommentCell") as? PostCommentTableViewCell {
          cell.media = media
          cell.delegate = self
          cell.selectionStyle = .None
          return cell
        }
        break
      default:
        if let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as? CommentsTableViewCell {
          if let media = media, comments = media.comments {
            cell.configureWithComment(comments[indexPath.row - 1])
            return cell
          }
        }
      }
      //default return blank cell
      let cell = UITableViewCell()
      return cell
    }
  
  @IBAction func backButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func updateCommentCount() {
    self.delegate?.updateCommentCount()
    self.tableView.reloadData()
    //update the comment on the playerCell too
  }
  
  func showUserProfile(user: User) {
    self.userForProfile = user
    self.performSegueWithIdentifier("showUserProfile", sender: self)
  }
  
  func showTaggedUsers(users: Array<User>, media: MediaObject) {
    //show the users
    self.taggedUsersForShow = users
    self.mediaForTagged = media
    self.performSegueWithIdentifier("showTaggedSegue", sender: self)
  }
  
  func showUploaderUser(user: User, media: MediaObject) {
    //show the users profile
    self.isShowingForGallery = true
    showUserProfile(user)
  }
  
  func userAdded(user: User) {
    //somehow show the user is added on the appropriate cell.....
    //dont have to cause dont show on the collection cell?
    self.media?.tagUserOnMedia(user)
    if let media = self.media {
      self.headerView?.configureForMedia(media, primaryUser: nil, delegate: self)
    }
    self.tableView.reloadData()
  }
  
}
