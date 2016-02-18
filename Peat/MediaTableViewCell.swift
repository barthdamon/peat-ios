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
  
  @IBOutlet weak var purposeLabel: UILabel!
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var descriptionView: UIView!

  @IBOutlet weak var likeButton: UIButton!
  @IBOutlet weak var postButton: UIButton!
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
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaSaved", name: "leafMediaPublished", object: nil)
  }
  
  func configureForImage() {
    if let mediaView = self.mediaView {
      self.overlayView = MediaOverlayView(mediaView: mediaView, player: nil, mediaObject: self.media, delegate: self)
    }
  }
  
  func configureForVideo() {
    if let media = self.media, mediaView = self.mediaView {
      self.player = PeatAVPlayer(playerView: mediaView, media: media)
      self.overlayView = MediaOverlayView(mediaView: mediaView, player: self.player, mediaObject: self.media, delegate: self)
      self.mediaView.userInteractionEnabled = true
      self.overlayView?.userInteractionEnabled = true
    }
  }
  
  func configureDescriptionSection() {
    if let media = media {
      self.descriptionLabel.text = media.mediaDescription
      if let purpose = media.purpose {
        self.purposeLabel.text = purpose.rawValue
      }
      updateCommentCount()
      if media.needsPublishing {
        toggleCommentSection(false)
      }
    }
  }
  
  func mediaSaved() {
    if let media = self.media {
      if !media.needsPublishing {
        toggleCommentSection(true)
      }
    }
  }
  
  func toggleCommentSection(enabled: Bool) {
    likeCountButton.enabled = enabled
    commentCountButton.enabled = enabled
    postButton.enabled = enabled
    likeButton.enabled = enabled
    commentTextField.userInteractionEnabled = enabled
  }
  
  func updateCommentCount() {
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
    if let mediaId = media?.mediaId, user = CurrentUser.info.model {
      let like = Like.newLike(user, mediaId: mediaId, comment_Id: nil)
      PeatSocialMediator.sharedMediator.newLike(like) { (success) in
        guard success else { /*show error*/return }
        //increase like count
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.media?.newLike(like)
          self.tableVC?.updateCommentCount()
        })
      }
    }
  }
  
  @IBAction func postButtonPressed(sender: AnyObject) {
    //post comment
    if let text = self.commentTextField.text, mediaId = media?.mediaId, user = CurrentUser.info.model {
      let comment = Comment.newComment(text, mediaId: mediaId, user: user)
      PeatSocialMediator.sharedMediator.newComment(comment) { (success) in
        guard success else { /*show error*/return }
        //add a new comment to ui
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.media?.newComment(comment)
          self.tableVC?.updateCommentCount()
          self.commentTextField.text = ""
          self.commentTextField.resignFirstResponder()
        })
      }
    }
    
  }
  
}
