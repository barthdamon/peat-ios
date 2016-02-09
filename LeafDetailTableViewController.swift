//
//  LeafDetailTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/20/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class LeafDetailTableViewController: UITableViewController {
  
    var leaf: Leaf? {
      return PeatContentStore.sharedStore.treeStore.selectedLeaf
    }
    var activityIndicator: UIActivityIndicatorView?
    var playerCells: Array<MediaTableViewCell> = []
  
    var mediaOnLoad: Array<MediaObject>?
    var viewing: User?
  
  var detailVC: LeafDetailViewController?

    override func viewDidLoad() {
      super.viewDidLoad()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "newMediaAdded", name: "newMediaPostSuccessful", object: nil)
    }
  
  override func viewWillDisappear(animated: Bool) {
    for cell in playerCells {
      cell.player = nil
      cell.mediaView = nil
      cell.overlayView = nil
    }
    super.viewWillDisappear(true)
  }
  
  func newMediaAdded() {
    self.tableView.reloadData()
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
      if let leaf = leaf, media = leaf.media {
        self.mediaOnLoad = media
//        return media.count
        return 1
      } else {
        return 0
      }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if let cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as? MediaTableViewCell, media = mediaOnLoad {
          let cellMedia = media[indexPath.row]
          cell.viewing = viewing
          cell.tableVC = self
          cell.configureWithMedia(cellMedia)
          self.playerCells.append(cell)
          return cell
      } else {
        let cell = UITableViewCell()
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
  
  func updateCommentCount() {
    for cell in self.playerCells {
      cell.updateCommentCount()
    }
  }
  
  func commentsButtonPressed(media: MediaObject?) {
    if let media = media {
      detailVC?.showCommentsForMedia(media)
    }
  }
  
  func likesButtonPressed(media: MediaObject?) {
    if let media = media {
      detailVC?.showLikesForMedia(media)
    }
  }

}
