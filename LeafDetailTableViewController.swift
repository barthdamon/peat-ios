//
//  LeafDetailTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/20/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

enum LeafFeedMode {
  case Uploads
  case Feed
  case Tutorials
}

class LeafDetailTableViewController: UITableViewController, TableViewForMedia, MediaHeaderCellDelegate, MediaTagUserDelegate, UIPopoverPresentationControllerDelegate {
  
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
  
  var mode: LeafFeedMode = .Uploads
  
  var leafFeedMedia: Array<MediaObject>?
  var tutorialFeedMedia: Array<MediaObject>?
  
  var mediaObjects: Array<MediaObject>? {
    switch mode {
    case .Uploads:
      return leaf?.media
    case .Feed:
      return leafFeedMedia
    case .Tutorials:
      return tutorialFeedMedia
    }
  }
  
  var uploaderUserForShow: User?
  var taggedUsersForShow: Array<User>?
  var mediaForTagged: MediaObject?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.clipsToBounds = true
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    //      NSNotificationCenter.defaultCenter().addObserver(self, selector: "newMediaAdded", name: "newMediaPostSuccessful", object: nil)
    setMode()
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
  
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.playerCells = Array()
      self.tableView.reloadData()
    })
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
      case .Uploaded:
        mode = .Uploads
        self.reload()
      default:
        mode = .Feed
        self.reload()
      }
      self.detailVC?.modeSet(self.mode)
    }
  }
  
  func getLeafFeed() {
    if let leaf = leaf {
      store?.getLeafFeed(leaf) { (objects) in
        if let objects = objects {
          self.leafFeedMedia = objects["leafFeed"] as? Array<MediaObject>
          self.tutorialFeedMedia = objects["tutorialFeed"] as? Array<MediaObject>
        } else {
          self.reload()
          print("No Media to show for feed")
        }
      }
    }
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
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 350
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let media = self.mediaObjects {
      do {
        let currentObject = try media.lookup(UInt(section))
        return createHeaderForMedia(currentObject)
      }
      catch {
        print("Error making header view")
      }
    }
    return nil
  }
  
  func createHeaderForMedia(currentObject: MediaObject) -> MediaCellHeaderView? {
    if let headerView = NSBundle.mainBundle().loadNibNamed("MediaCellHeader", owner: self, options: nil).first as? MediaCellHeaderView {
      headerView.frame = CGRectMake(0,0,tableView.frame.width, 50)
      let primaryUser = viewing != nil ? viewing : CurrentUser.info.model
      switch mode {
      case .Feed, .Tutorials:
        headerView.configureForMedia(currentObject, primaryUser: nil, delegate: self)
      case .Uploads:
        headerView.configureForMedia(currentObject, primaryUser: primaryUser, delegate: self)
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
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
    
//    if segue.identifier == "showUserGallery" {
//      if let vc = segue.destinationViewController as? GalleryCollectionViewController {
//        vc.viewing = uploaderUserForShow
//        vc.setViewForStacked()
//      }
//    }
  }

  
  func updateCommentCount() {
    for cell in self.playerCells {
      cell.updateCommentCount()
    }
  }
  
  func commentsButtonPressed(media: MediaObject?) {
    if let media = media, headerView = createHeaderForMedia(media) {
      detailVC?.showCommentsForMedia(media, headerView: headerView)
    }
  }
  
  func likesButtonPressed(media: MediaObject?) {
    if let media = media {
      detailVC?.showLikesForMedia(media)
    }
  }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  
  func userAdded(user: User) {
    //somehow show the user is added on the appropriate cell.....
  }
  
  func userIsTagged(user: User) -> Bool {
    //somehow get the tagged users here
    return false
  }
  
  //not used
  func showUserProfile(user: User) {
    self.detailVC?.showUserProfile(user)
  }
  
  //trying to use
  func showUploaderGallery(user: User) {
    self.detailVC?.showUploaderGallery(user)
  }
  
  
  //MARK: MediaHeaderCellDelegate
  
  //USED
  func showTaggedUsers(users: Array<User>, media: MediaObject) {
    self.taggedUsersForShow = users
    self.mediaForTagged = media
    self.performSegueWithIdentifier("showTaggedSegue", sender: self)
  }
  
  //half used
  func showUploaderUser(user: User, media: MediaObject) {
    showUploaderGallery(user)
//    self.detailVC?.showUploaderGallery()
//    self.uploaderUserForShow = user
//    self.performSegueWithIdentifier("showUserGallery", sender: self)
  }
  
}

