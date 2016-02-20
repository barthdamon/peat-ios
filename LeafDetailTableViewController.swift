//
//  LeafDetailTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/20/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

enum LeafFeedMode {
  case Feed
  case Set
  case None
}

class LeafDetailTableViewController: UITableViewController, TableViewForMedia {
  
    var API = APIService.sharedService
  
    var leaf: Leaf? {
      return store?.treeStore.selectedLeaf
    }
    var store: PeatContentStore? {
      return detailVC?.profileDelegate?.store
    }
    var activityIndicator: UIActivityIndicatorView?
    var playerCells: Array<MediaTableViewCell> = []
  
    var viewing: User?
  
    var detailVC: LeafDetailViewController?
  
    var mode: LeafFeedMode = .Set
    
    var leafFeedMedia: Array<MediaObject>?
      
    var mediaObjects: Array<MediaObject>? {
      switch mode {
      case .Set:
        return leaf?.media
      case .Feed:
        return leafFeedMedia
      case .None:
        return nil
      }
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      self.tableView.clipsToBounds = true
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "newMediaAdded", name: "newMediaPostSuccessful", object: nil)
    }
  
  func fixTableViewInsets() {
    let zContentInsets = UIEdgeInsetsZero
    self.tableView.contentInset = zContentInsets
    self.tableView.scrollIndicatorInsets = zContentInsets
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    fixTableViewInsets()
  }
  
  override func viewWillDisappear(animated: Bool) {
    for cell in playerCells {
      cell.player?.stopPlaying()
      cell.player = nil
      cell.mediaView = nil
      cell.overlayView = nil
    }
    super.viewWillDisappear(true)
  }
  
  func setMode() {
    if let status = leaf?.completionStatus {
      switch status {
      case .Completed:
        mode = .Set
        self.tableView.reloadData()
      case .Goal, .Learning where viewing == nil:
        mode = .Feed
        getLeafFeed()
      default:
        mode = .None
        self.tableView.reloadData()
      }
      self.detailVC?.modeSet(self.mode)
    }
  }
  
  func getLeafFeed() {
    if let leaf = leaf {
      store?.getLeafFeed(leaf) { (mediaObjects) in
        if let objects = mediaObjects {
          self.leafFeedMedia = objects
          self.tableView.reloadData()
        } else {
          self.mode = .None
          self.tableView.reloadData()
          print("No Media to show for feed")
        }
      }
    }
  }
  
  func newMediaAdded() {
    self.mode = .Set
    self.tableView.reloadData()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
      return mediaObjects != nil ? mediaObjects!.count : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return 1
    }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let headerView = NSBundle.mainBundle().loadNibNamed("MediaCellHeader", owner: self, options: nil).first as? MediaCellHeaderView, media = self.mediaObjects {
      headerView.frame = CGRectMake(0,0,tableView.frame.width, 50)
      do {
        let currentObject = try media.lookup(UInt(section))
        let primaryUser = viewing != nil ? viewing : CurrentUser.info.model
        headerView.configureForMedia(currentObject, primaryUser: primaryUser)
      }
      catch {
        print("Error making header view")
      }
      return headerView
    } else {
      return nil
    }
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = cell as? MediaTableViewCell {
      cell.player?.stopPlaying()
      cell.player = nil
    }
  }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if let cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as? MediaTableViewCell, mediaObjects = mediaObjects {
        let cellMedia = mediaObjects[indexPath.section]
        cell.viewing = viewing
        cell.delegate = self
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
