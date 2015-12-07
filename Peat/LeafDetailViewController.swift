//
//  LeafDetailViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/5/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class LeafDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var leaf: LeafNode?
  var media: Array<MediaObject>?
  var currentMedia: MediaObject?
  var mediaDescription: String?
  var player: PeatAVPlayer?
  var mediaImage: UIImage?
  var imageDisplay: UIImageView?

  //Views
  @IBOutlet weak var navBarView: UIView!
  @IBOutlet weak var tabBarView: UIView!
  @IBOutlet weak var titleView: UIView!
  @IBOutlet weak var commentView: UIView!
  @IBOutlet weak var commentTableView: UITableView!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var playerView: UIView!
  @IBOutlet weak var abilityTitle: UILabel!
  @IBOutlet weak var completionStatusLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBarHidden = true
  }
  
  override func viewDidLayoutSubviews() {
    configureAbilityLayout()
  }

  func configureAbilityLayout() {
    if let title = leaf?.abilityTitle, status = leaf?.completionStatus {
      self.abilityTitle.text = title
      self.completionStatusLabel.text = status ? "Completed" : "Incomplete"
      if let mediaIds = leaf?.mediaIds {
        self.media = PeatContentStore.sharedStore.findMediaWithIds(mediaIds)
      }
    }
    showPresentMedia()
  }
  
  func showPresentMedia() {
    if let media = self.media {
      if media.count > 0 {
        currentMedia = media[0]
        if let selectedMedia = currentMedia, description = selectedMedia.mediaDescription {
          print("Media description: \(description)")
          //TODO: Need to deal with getting the video thumbnail from the video at time x
          selectedMedia.generateThumbnail(selectedMedia) { (thumbnail, err) in
            if let thumbnail = thumbnail {
              if let _ = selectedMedia as? PhotoObject {
                self.configureMediaViewWithImage(thumbnail)
              } else {
                if let object = selectedMedia as? VideoObject, url = object.url {
                  self.player = PeatAVPlayer(playerView: self.playerView, media: selectedMedia, url: url, thumbnail: thumbnail)
                }
              }
            }
          }
        }
      }
    }
  }
  
  func configureMediaViewWithImage(image: UIImage) {
//    self.descriptionLabel.text = self.currentMedia?.description
    self.imageDisplay = UIImageView()
    if let display = self.imageDisplay {
      display.frame = self.playerView.bounds
      display.contentMode = .ScaleAspectFill
      display.image = image
      self.playerView.addSubview(display)
    }
  }
  
  @IBAction func completionButtonPressed(sender: AnyObject) {
    self.tabBarController?.selectedIndex = 3
  }
  
  @IBAction func backButtonPressed(sender: AnyObject) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  
  //MARK: Table View
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = MediaDescriptionTableViewCell()
    return cell
  }

}
