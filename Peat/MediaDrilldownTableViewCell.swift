//
//  MediaDrilldownTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/8/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class MediaDrilldownTableViewCell: UITableViewCell {

  @IBOutlet weak var purposeLabel: UILabel!
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var descriptionView: UIView!
  
  @IBOutlet weak var likeCountButton: UIButton!
  @IBOutlet weak var commentCountButton: UIButton!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  
  @IBOutlet weak var commentTextField: UITextField!
  
  var tableVC: CommentsTableViewController?
  
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
    if let purpose = media.purpose {
      self.purposeLabel.text = purpose.rawValue
    }
    self.descriptionLabel.text = media.mediaDescription
    updateCommentCount()
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
  
  @IBAction func likeCountButtonPressed(sender: AnyObject) {
    //show other people that have liked
  }
  
  @IBAction func likeButtonPressed(sender: AnyObject) {
    //send like
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
  
  
  @IBAction func backButtonPressed(sender: AnyObject) {
    self.tableVC?.navigationController?.popToRootViewControllerAnimated(true)
  }

}
