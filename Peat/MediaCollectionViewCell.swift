//
//  MediaCollectionViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class MediaCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var titleOverlayView: UIView!
  @IBOutlet weak var uploadedOnTextLabel: UILabel!
  @IBOutlet weak var uploaderUserButton: UIButton!
  
  var media: MediaObject?
  var mediaOverlayView: MediaOverlayView?
  
  func configureWithMedia(media: MediaObject) {
    if let uploaderName = media.uploaderUser?.username {
      self.uploaderUserButton.setTitle(uploaderName, forState: .Normal)
    }
    
    if let date = media.datePosted?.shortString {
      self.uploadedOnTextLabel.text = "\(date) by"
    }
    
    self.mediaOverlayView = MediaOverlayView(mediaView: mediaView, player: nil, mediaObject: media, delegate: self)
    
  }
  
  
  @IBAction func uploaderUserButtonPressed(sender: AnyObject) {
    
  }
  
  
}
