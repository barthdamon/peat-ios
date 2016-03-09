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


class GalleryCollectionViewController: UICollectionViewController, MediaUploadDelegate {
  
  var viewing: User?
  var store = PeatContentStore()
  var sidebarClient: SideMenuClient?
  
  var mediaCollectionCells: Array<MediaCollectionViewCell>?
  
  var mode: GallerySelectionMode = .View
  
  var mediaObjects: Array<MediaObject>? {
//    if let delegate = profileDelegate {
//      return store.gallery.mediaObjects?.filter({ (object) -> Bool in
//        object.activityName == delegate.currentActivity?.name
//      })
//    } else {
      return store.gallery.mediaObjects
//    }
  }
  var uploads: Array<MediaObject>? {
    return mediaObjects?.filter({$0.uploaderUser_Id == CurrentUser.info.model?._id})
  }
  var tagged: Array<MediaObject>? {
    return mediaObjects?.filter({$0.uploaderUser_Id != CurrentUser.info.model?._id})
  }
  
  var selectedMediaObject: MediaObject?
  var mediaUploadController: MediaUploadViewController?
  var profileDelegate: ProfileViewController?
  var stacked = false
  var commentsView: CommentsTableViewController?
  
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
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewMedia")
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
    return 2
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let defaultView = UICollectionReusableView()
    if (kind == UICollectionElementKindSectionHeader) {
      if let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "headerView", forIndexPath: indexPath) as? GalleryHeaderCollectionReusableView {
        let title = indexPath.section == 0 ? "Uploads" : "Tagged"
        view.configureWithTitle(title)
        return view
      }
    }
    return defaultView
  }
  
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    if section == 0 {
      return uploads != nil && tagged?.count != 0 ? uploads!.count : 1
    } else {
      return tagged != nil && tagged?.count != 0 ? tagged!.count : 1
    }
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var message = "No Media Found"
    do {
      let objects = indexPath.section == 0 ? self.uploads : self.tagged
      let media = try objects?.lookup(UInt(indexPath.row))
      if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MediaCollectionViewCell", forIndexPath: indexPath) as? MediaCollectionViewCell, media = media {
        cell.configureWithMedia(media)
        return cell
      }
    }
    catch {
      message = indexPath.section == 0 ? "No Uploads Found" : "Not Tagged Items"
    }
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DefaultMediaCell", forIndexPath: indexPath) as! DefaultCollectionViewCell
    print(message)
    cell.configureWithMessage(message)
    return cell
  }
  
  // MARK: UICollectionViewDelegate
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    do {
      let objects = indexPath.row == 0 ? self.uploads : self.tagged
      self.selectedMediaObject = try objects?.lookup(UInt(indexPath.row))
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
        self.commentsView = vc
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
      if let delegate = self.commentsView {
        headerView.configureForMedia(currentObject, primaryUser: nil, delegate: delegate)
      }
      return headerView
    } else {
      return nil
    }
  }
  
  func addNewMedia() {
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
