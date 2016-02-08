//
//  MediaTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


class MediaTableViewCell: UITableViewCell {
  
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var descriptionView: UIView!

  @IBOutlet weak var likeCountButton: UIButton!
  @IBOutlet weak var commentCountButton: UIButton!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  
  @IBOutlet weak var commentTextField: UITextField!
  
  var tableVC: LeafDetailTableViewController?
  
  var media: MediaObject?
  var viewing: User?
  
  var videoPath: NSURL?
  var player: PeatAVPlayer?
  var overlayView: MediaOverlayView?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func playSelectedMedia() {
    //when video view cell gets tapped it should play the media.
    self.player?.playButtonPressed()
  }
  
  func configureWithMedia(media: MediaObject) {
    self.media = media
    self.selectionStyle = UITableViewCellSelectionStyle.None
    if let type = media.mediaType {
      switch type {
      case .Video:
        configureForVideo()
      case .Image:
        configureForImage()
      default:
        break
      }
    }
    configureDescriptionSection()
  }
  
  func configureForImage() {
    self.overlayView = MediaOverlayView(mediaView: self.mediaView, player: nil, mediaObject: self.media, delegate: self)
  }
  
  func configureForVideo() {
    if let media = self.media {
      self.player = PeatAVPlayer(playerView: self.mediaView, media: media)
      self.overlayView = MediaOverlayView(mediaView: self.mediaView, player: self.player, mediaObject: self.media, delegate: self)
      self.mediaView.userInteractionEnabled = true
      self.overlayView?.userInteractionEnabled = true
    }
  }
  
  func configureDescriptionSection() {
    self.descriptionLabel.text = media?.mediaDescription
    var likesCount = 0
    var commentsCount = 0
    if let likes = media?.likes {
      likesCount = likes.count
    }
    if let comments = media?.comments {
      commentsCount = comments.count
    }
    likeCountButton.setTitle("\(likesCount) Likes", forState: .Normal)
    commentCountButton.setTitle("\(commentsCount) Comments", forState: .Normal)
  }
  
  //MARK: Comment Section
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  

  @IBAction func commentCountButtonPressed(sender: AnyObject) {
    tableVC?.commentsButtonPressed(media)
  }
  
  @IBAction func likeCountButtonPressed(sender: AnyObject) {
    //show other people that have liked
  }
  
  @IBAction func likeButtonPressed(sender: AnyObject) {
    //send like
    if let media = media {
      PeatSocialMediator.sharedMediator.newLike(media, comment: nil) { (success) in
        guard success else { /*show error*/return }
        //increase like count
      }
    }
  }
  
  @IBAction func postButtonPressed(sender: AnyObject) {
    //post comment
    if let text = self.commentTextField.text, media = media {
      PeatSocialMediator.sharedMediator.newComment(text, media: media) { (success) in
        guard success else { /*show error*/return }
        //add a new comment to ui
        
      }
    }
    
  }
  
}
