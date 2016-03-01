//
//  GalleryCollectionViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/21/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MediaCollectionViewCell"

enum GallerySelectionMode {
  case Upload
  case View
}


class GalleryCollectionViewController: UICollectionViewController, MediaUploadDelegate, MediaHeaderCellDelegate {
  
  var viewing: User?
  var store = PeatContentStore()
  var sidebarClient: SideMenuClient?
  
  var mediaCollectionCells: Array<MediaCollectionViewCell>?
  
  var mode: GallerySelectionMode = .View
  
  var mediaObjects: Array<MediaObject>? {
    return store.gallery.mediaObjects
  }
  var selectedMediaObject: MediaObject?
  var mediaUploadController: MediaUploadViewController?
  
  var profileDelegate: ProfileViewController?
  
  var stacked = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !stacked {
      initializeSidebar()
      configureMenuSwipes()
      configureNavBar()
    }

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Register cell classes
//    self.collectionView!.registerClass(MediaCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    if let _ = self.viewing {
    } else {
      self.store = CurrentUser.info.store
      let recognizer = UITapGestureRecognizer(target: self, action: "collectionViewDoubleTapped:")
      recognizer.numberOfTapsRequired = 2
      recognizer.numberOfTouchesRequired = 1
      self.collectionView?.addGestureRecognizer(recognizer)
    }
    initializeGallery()
    // Do any additional setup after loading the view.
  }
  
  func setForStackedView() {
//    self.navigationController?.navigationBarHidden = false
//    print("self.navigationContrlller: \(self.navigationController)")
//    let backButton = UIBarButtonItem(barButtonSystemItem: .PageCurl, target: self, action: "dismissSelf")
//    self.navigationItem.leftBarButtonItem = backButton
    stacked = true
//    stacked = true
  }
  
  override func viewDidAppear(animated: Bool) {
    reload()
  }
  
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.collectionView?.reloadData()
    })
  }
  
  func initializeGallery() {
    var id = ""
    if let viewing_Id = viewing?._id {
      id = viewing_Id
    } else if let current_Id = CurrentUser.info.model?._id {
      id = current_Id
    }
    self.store.gallery.initializeGallery(id, callback: { (success) -> () in
      if success {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.reload()
        })
      } else {
        //show error
        print("Error initializing gallery")
      }
    })
  }
  
  func addMediaToGallery() {
    self.performSegueWithIdentifier("showMediaUpload", sender: self)
  }
  
  func newMediaAdded() {
    let store = self.store
    self.reload()
  }
  
  func getStore() -> PeatContentStore? {
    return self.store
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  }
  */
  
  // MARK: UICollectionViewDataSource
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return mediaObjects != nil ? mediaObjects!.count : 0
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MediaCollectionViewCell
    if let mediaObjects = mediaObjects {
      do {
        let media = try mediaObjects.lookup(UInt(indexPath.row))
        cell.configureWithMedia(media)
        return cell
      }
      catch {
        print("Error finding media")
      }
    }
    // Configure the cell
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    do {
      self.selectedMediaObject = try mediaObjects?.lookup(UInt(indexPath.row))
      switch mode {
      case .View:
        if let delegate = self.profileDelegate {
          delegate.showMediaFromGallery(self)
        } else {
          self.performSegueWithIdentifier("showMediaDrilldownDetail", sender: self)
        }
      case .Upload:
        if let controller = mediaUploadController, object = selectedMediaObject {
          controller.mediaFromGallery(object)
          self.navigationController?.popViewControllerAnimated(true)
        }
      }
    }
    catch {
      print("Media not found for selected Cell")
    }
  }
  
  /*
  // Uncomment this method to specify if the specified item should be highlighted during tracking
  override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
  return true
  }
  */
  
  /*
  // Uncomment this method to specify if the specified item should be selected
  override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
  return true
  }
  */
  
  /*
  // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
  override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
  return false
  }
  
  override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
  return false
  }
  
  override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
  
  }
  */
  
  //MARK: Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showMediaDrilldownDetail" {
      if let vc = segue.destinationViewController as? CommentsTableViewController, media = selectedMediaObject {
        vc.media = media
        vc.viewing = self.viewing
        if let newHeader = createHeaderForMedia(media) {
          vc.headerView = newHeader
        }
      }
    }
    
    if segue.identifier == "showMediaUpload" {
      if let vc = segue.destinationViewController as? MediaUploadViewController {
        vc.delegate = self
      }
    }
  }
  
  func createHeaderForMedia(currentObject: MediaObject) -> MediaCellHeaderView? {
    if let headerView = NSBundle.mainBundle().loadNibNamed("MediaCellHeader", owner: self, options: nil).first as? MediaCellHeaderView, view = self.view {
      headerView.frame = CGRectMake(0,0,view.frame.width, 50)
      headerView.configureForMedia(currentObject, primaryUser: nil, delegate: self)
      return headerView
    } else {
      return nil
    }
  }
  
  func showTaggedUsers(users: Array<User>, media: MediaObject) {
    //show the users
  }
  
  func showUploaderUser(user: User, media: MediaObject) {
    //show the users profile
  }
  
  func userAdded(user: User) {
    //somehow show the user is added on the appropriate cell.....
  }
  
  func userIsTagged(user: User) -> Bool {
    //somehow get the tagged users here
    return false
  }
  
  
  func collectionViewDoubleTapped(sender: UIGestureRecognizer) {
    self.addMediaToGallery()
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
