//
//  VideoOverlayView.swift
//  Peat
//
//  Created by Matthew Barth on 12/6/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class VideoOverlayView: UIView {

    //passed in
    var playerController: AnyObject!
    var playerContainer: UIView!
    var thumbnail: UIImage?
    var mediaObject: MediaObject?
  
    var videoOverlayView: UIView?
    var overlayButton: UIImageView?
    var liveStreamHeaderView: UIView?
    var playButtonIcon = UIImage(named: "icon_play_solid")
    
    init(container: UIView, playerController: AnyObject, mediaObject: MediaObject?, thumbnail: UIImage?) {
      self.playerContainer = container
      self.thumbnail = thumbnail
      self.playerController = playerController
      self.mediaObject = mediaObject
      super.init(frame: self.playerContainer.bounds)
      configureThumbnailOverlay()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    func configureThumbnailOverlay() {
      
      let thumbnailView = UIImageView(frame: self.bounds)
      thumbnailView.contentMode = .ScaleAspectFit
      thumbnailView.image = thumbnail
      thumbnailView.accessibilityIdentifier = thumbnail?.accessibilityIdentifier
      
      self.addSubview(thumbnailView)
      
      let playButtonContainerSize: CGFloat = 70
      
      let playButtonContainer = UIView(frame: CGRectMake(0, 0, playButtonContainerSize, playButtonContainerSize))
      playButtonContainer.layer.cornerRadius = playButtonContainerSize/2;
      playButtonContainer.layer.masksToBounds = true
      playButtonContainer.backgroundColor = UIColor.whiteColor()
      playButtonContainer.alpha = 0.3
      playButtonContainer.center = self.center
      
      let playButton = UIImageView(image: self.playButtonIcon)
      
      playButton.center = playButtonContainer.center
      playButton.alpha = 0.6
      
      self.addSubview(playButtonContainer)
      self.addSubview(playButton)
      self.overlayButton = playButton
      

      self.gestureRecognizers?.removeAll()
      let tap = UITapGestureRecognizer(target: playerController, action: "playButtonPressed")
      tap.numberOfTapsRequired = 1
      tap.numberOfTouchesRequired = 1
      self.addGestureRecognizer(tap)

      
      playerContainer.addSubview(self)
      if let header = self.liveStreamHeaderView {
        header.alpha = 0.5
        playerContainer.bringSubviewToFront(header)
      }
    }
}
