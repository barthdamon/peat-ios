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
        return comments.count + 1
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
        postIndex = comments.count
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
          cell.selectionStyle = .None
          return cell
        }
        break
      default:
        if let cell = tableView.dequeueReusableCellWithIdentifier("commentCell") as? CommentsTableViewCell {
          if let media = media, comments = media.comments {
            cell.configureWithComment(comments[indexPath.row])
            return cell
          }
        }
      }
      //default return blank cell
      let cell = UITableViewCell()
      return cell
    }
  
  

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
