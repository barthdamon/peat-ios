//
//  CommentsTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/7/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class CommentsTableViewController: UITableViewController {
  
  var media: MediaObject?
  var viewing: User?
  
  var delegate: LeafDetailViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      var postIndex = 1
      if let comments = media?.comments {
        postIndex = comments.count + 1
      }
      switch indexPath.row {
      case 0:
        if let cell = tableView.dequeueReusableCellWithIdentifier("descriptionCell") as? MediaDescriptionTableViewCell, media = media {
          let user = viewing != nil ? viewing! : CurrentUser.info.model!
          cell.configureWithMediaAndUser(media, user: user)
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
  
  
  func updateCommentCount() {
    self.delegate?.updateCommentCount()
    self.tableView.reloadData()
    //update the comment on the playerCell too
  }
}
