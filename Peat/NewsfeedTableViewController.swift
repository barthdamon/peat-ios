//
//  NewsfeedTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class NewsfeedTableViewController: UITableViewController, ViewControllerWithMenu, TableViewForMedia, CommentDetailDelegate, MediaHeaderCellDelegate {
  
    var mediaObjects: Array<MediaObject>?
    var sidebarClient: SideMenuClient?
    var playerCells: Array<MediaTableViewCell> = []
  
    var selectedMediaForComments: MediaObject?
    var selectedHeaderViewForComments: MediaCellHeaderView?
  
    var activityFilter: Activity?
  
    var API = APIService.sharedService
  
  var userForProfile: User?
  var isShowingForGallery = false
  
    override func viewDidLoad() {
      super.viewDidLoad()
      self.tableView.allowsSelection = false
//      NSNotificationCenter.defaultCenter().addObserver(self, selector: "configureMedia", name: "mediaObjectsPopulated", object: nil)
      
      initializeSidebar()
      configureNavBar()
      configureMenuSwipes()
      getNewsfeed()
    }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)
//    if let mediaObjects = PeatContentStore.sharedStore.mediaObjects {
//      self.mediaObjects = mediaObjects
//      checkForNewsfeedUpdates()
//    } else {
//      queryForMediaData()
//    }
  }
  
  func checkForNewsfeedUpdates() {
//    PeatContentStore.sharedStore.updateNewsfeed() { (res, err) -> () in
//      if err != nil {
//        print("error updating newsfeed")
//      } else {
//        print("Newsfeed update complete")
//        if let mediaObjects = res as? Array<MediaObject> {
//          self.mediaObjects?.removeAll()
//          self.configureMedia(mediaObjects)
//        }
//      }
//    }
  }
  
  func getNewsfeed() {
    var url = "news/all"
//    if let name = activityFilter?.name {
//      url = "news/\(name)"
//    }
    API.get(nil, authType: .Token, url: url) { (res, err) -> () in
      if let e = err {
        print("Error fetching newsfeed \(e)")
      } else {
        print("RES: \(res)")
        if let json = res as? jsonObject {
          if let newsfeed = json["newsfeed"] as? jsonObject,
            mediaObjectJson = newsfeed["media"] as? Array<jsonObject> {
            self.mediaObjects = Array()
            mediaObjectJson.forEach({ (object) -> () in
              self.mediaObjects!.append(MediaObject.initWithJson(object, store: nil))
            })
          }
          if let following = json["following"] as? Array<jsonObject> {
            CurrentUser.info.model?.addFollowing(following)
          }
          self.reload()
        }
      }
    }
  }

    // MARK: - Table view data source
  
  func reload() {
    self.playerCells = Array()
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      let count = self.mediaObjects != nil ? self.mediaObjects!.count : 0
      return count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
      headerView.configureForMedia(currentObject, primaryUser: nil, delegate: self)
      return headerView
    } else {
      return nil
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as? MediaTableViewCell, mediaObjects = mediaObjects {
      let cellMedia = mediaObjects[indexPath.section]
      cell.delegate = self
      cell.configureWithMedia(cellMedia)
      self.playerCells.append(cell)
      return cell
    } else {
      let cell = UITableViewCell()
      return cell
    }
  }
  
  //MARK: Table View For Media Delegate Methods
  func updateCommentCount() {
    for cell in self.playerCells {
      cell.updateCommentCount()
    }
  }
  
  func commentsButtonPressed(media: MediaObject?) {
    if let media = media {
      self.selectedMediaForComments = media
      self.selectedHeaderViewForComments = createHeaderForMedia(media)
      self.performSegueWithIdentifier("showComments", sender: self)
    }
  }
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showComments" {
      if let vc = segue.destinationViewController as? CommentsTableViewController {
        vc.media = selectedMediaForComments
        vc.viewing = nil
        vc.delegate = self
        if let newHeader = self.selectedHeaderViewForComments {
          vc.headerView = newHeader
        }
      }
    }
    
    if segue.identifier == "showUserProfile" {
      if let vc = segue.destinationViewController as? ProfileViewController {
        vc.viewing = userForProfile
        vc.setForStackedView()
        vc.isShowingForGallery = isShowingForGallery
        isShowingForGallery = false
      }
    }
  }

  //USED:
  func showTaggedUsers(users: Array<User>, media: MediaObject) {
    //show the users
    
  }
  
  func showUploaderUser(user: User, media: MediaObject) {
    //show the users profile
  }
  
  func showUserProfile(user: User) {
    self.userForProfile = user
    self.performSegueWithIdentifier("showUserProfile", sender: self)
  }
  
  func showUploaderGallery(user: User) {
    self.userForProfile = user
    self.isShowingForGallery = true
    self.performSegueWithIdentifier("showUserProfile", sender: self)
  }
  
  
  //NOT USED:
  func userAdded(user: User) {
    //somehow show the user is added on the appropriate cell.....
  }
  
  func userIsTagged(user: User) -> Bool {
    //somehow get the tagged users here
    return false
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

}
