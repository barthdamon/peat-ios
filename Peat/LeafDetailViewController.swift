//
//  LeafDetailViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/5/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class LeafDetailViewController: UIViewController {
  
  var leaf: LeafNode?
  var media: Array<MediaObject>?
  var currentMedia: MediaObject?
  var mediaImage: UIImage?
  var imageDisplay: UIImageView?

  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var playerView: UIView!
  @IBOutlet weak var abilityTitle: UILabel!
  @IBOutlet weak var completionStatusLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
        if let selectedMedia = currentMedia, url = selectedMedia.url, description = selectedMedia.mediaDescription {
          self.descriptionLabel.text = description
          if let object = selectedMedia as? PhotoObject {
            if let thumbnail = object.thumbnail {
              configureMediaViewWithImage(thumbnail)
            } else {
              if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                self.mediaImage = image
                object.thumbnail = image
                configureMediaViewWithImage(image)
              }
            }
          } else {
            
          }
        }
      }
    }
  }
  
  func configureMediaViewWithImage(image: UIImage) {
    self.descriptionLabel.text = self.currentMedia?.description
    self.imageDisplay = UIImageView()
    if let display = self.imageDisplay {
      display.frame = self.playerView.bounds
      display.contentMode = .ScaleAspectFit
      display.image = image
      self.playerView.addSubview(display)
    }
  }
  
  @IBAction func completionButtonPressed(sender: AnyObject) {
    self.completionStatusLabel.text = "Completed"
    leaf?.completionStatus = true
  }

}
