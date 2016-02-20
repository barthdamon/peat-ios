//
//  NewsfeedTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class NewsfeedTableViewController: UITableViewController, ViewControllerWithMenu, TableViewForMedia {
  
    var mediaObjects: Array<MediaObject>?
    var sidebarClient: SideMenuClient?
    var playerCells: Array<MediaTableViewCell> = []
    var selectedMediaForComments: MediaObject?
  
    var activityFilter: Activity?
  
    var API = APIService.sharedService
  
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
    if let name = activityFilter?.name {
      url = "news/\(name)"
    }
    API.get(nil, authType: .Token, url: url) { (res, err) -> () in
      if let e = err {
        print("Error fetching newsfeed \(e)")
      } else {
        print("RES: \(res)")
        if let json = res as? jsonObject, newsfeed = json["newsfeed"] as? jsonObject,
          mediaObjectJson = newsfeed["media"] as? Array<jsonObject> {
            self.mediaObjects = Array()
            mediaObjectJson.forEach({ (object) -> () in
              self.mediaObjects!.append(MediaObject.initWithJson(object, store: nil))
            })
            self.tableView.reloadData()
        }
      }
    }
  }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return self.mediaObjects != nil ? self.mediaObjects!.count : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1
    }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let headerView = NSBundle.mainBundle().loadNibNamed("MediaCellHeader", owner: self, options: nil).first as? MediaCellHeaderView, media = self.mediaObjects {
      headerView.frame = CGRectMake(0,0,tableView.frame.width, 50)
      let currentObject = media[section]
      let primaryUser = CurrentUser.info.model
      headerView.configureForMedia(currentObject, primaryUser: primaryUser)
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
      self.performSegueWithIdentifier("showComments", sender: self)
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

}
