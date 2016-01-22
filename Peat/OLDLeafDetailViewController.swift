////
////  LeafDetailViewController.swift
////  Peat
////
////  Created by Matthew Barth on 11/5/15.
////  Copyright © 2015 Matthew Barth. All rights reserved.
////
//
//import UIKit
//
//class LeafDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//  
//  var leaf: Leaf?
//  var media: Array<MediaObject>?
//  var currentMedia: MediaObject?
//  var mediaDescription: String?
//  var player: PeatAVPlayer?
//  var mediaOverlayView: MediaOverlayView?
//
//
//  //Views
//  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
//  @IBOutlet weak var navBarView: UIView!
//  @IBOutlet weak var tabBarView: UIView!
//  @IBOutlet weak var titleView: UIView!
//  @IBOutlet weak var commentView: UIView!
//  @IBOutlet weak var commentTableView: UITableView!
//  
//  @IBOutlet weak var descriptionLabel: UILabel!
//  @IBOutlet weak var playerView: UIView!
//  @IBOutlet weak var abilityTitle: UILabel!
//  @IBOutlet weak var completionStatusLabel: UILabel!
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
////    self.navigationController?.navigationBarHidden = true
//    configureLoadingView()
//  }
//  
//  override func viewDidAppear(animated: Bool) {
//    configureAbilityLayout()
//  }
//  
//  override func viewWillDisappear(animated: Bool) {
//    self.player?.player?.pause()
//    self.player = nil
//    self.mediaOverlayView = nil
//    super.viewWillDisappear(true)
//  }
//  
//  func configureLoadingView() {
//    //configureForDefaultImage
//    self.playerView.backgroundColor = UIColor.blackColor()
//    //Starting:
//    activityIndicator.hidesWhenStopped = true
//    activityIndicator.startAnimating()
//  }
//
//  func configureAbilityLayout() {
//    if let title = leaf?.title, status = leaf?.completionStatus {
//      self.abilityTitle.text = title
////      self.completionStatusLabel.text = status ? "Completed" : "Incomplete"
//      if let mediaIds = leaf?.mediaIds {
////        self.media = PeatContentStore.sharedStore.findMediaWithIds(mediaIds)
//      }
//    }
//    showPresentMedia()
//  }
//  
//  func showPresentMedia() {
//    if let media = self.media {
//      if media.count > 0 {
//        currentMedia = media[0]
//        //Media Configuration
//        if let selectedMedia = currentMedia, url = selectedMedia.url {
//          print("Media description: \(description)")
//          if selectedMedia is VideoObject {
//            self.player = PeatAVPlayer(playerView: playerView, media: selectedMedia, url: url)
//          }
//          self.mediaOverlayView = MediaOverlayView(mediaView: playerView, player: self.player, mediaObject: selectedMedia, delegate: self)
//        }
//      }
//    }
//  }
//  
//  @IBAction func completionButtonPressed(sender: AnyObject) {
//    self.tabBarController?.selectedIndex = 3
//  }
//  
//  @IBAction func backButtonPressed(sender: AnyObject) {
//    self.navigationController?.popViewControllerAnimated(true)
//    self.player?.player?.pause()
//    self.player?.player = nil
//    self.player = nil
//    self.mediaOverlayView = nil
//  }
//  
//  
//  //MARK: Table View
//  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return 1
//  }
//  
//  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = MediaDescriptionTableViewCell()
//    return cell
//  }
//
//}
