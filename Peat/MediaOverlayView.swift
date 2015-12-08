//
//  MediaOverlayView.swift
//  Peat
//
//  Created by Matthew Barth on 12/6/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class MediaOverlayView: UIView {

    //passed in
    var player: PeatAVPlayer?
    var delegate: LeafDetailViewController?
    var mediaView: UIView!
    var thumbnail: UIImage?
    var mediaObject: MediaObject?
    var overlayButton: UIImageView?
    var playButtonIcon = UIImage(named: "icon_play_solid")
  
    init(mediaView: UIView, player: PeatAVPlayer?, mediaObject: MediaObject?, delegate: LeafDetailViewController) {
      self.mediaView = mediaView
      self.player = player
      self.mediaObject = mediaObject
      super.init(frame: self.mediaView.bounds)
      configureMediaView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  
    func configureMediaView() {
      if let object = self.mediaObject {
        switch object {
        case is VideoObject:
          configureForVideo()
        case is PhotoObject:
          configureForPhoto()
          break
        default:
          break
        }
      }
    }
  
    func configureForPhoto() {
      if let url = mediaObject?.url {
        UIImage.loadAsync(url, callback: { (image: UIImage) -> () in
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let imageDisplay = UIImageView()
            imageDisplay.frame = self.mediaView.bounds
            imageDisplay.contentMode = .ScaleAspectFill
            imageDisplay.image = image
            self.addSubview(imageDisplay)
            self.delegate?.activityIndicator.stopAnimating()
          })
        })
      }
    }
  
  func configureForVideo() {
    if let url = mediaObject?.url {
      let asset = AVURLAsset(URL: url)
      let imageGenerator = AVAssetImageGenerator(asset: asset)
      imageGenerator.appliesPreferredTrackTransform=true
      //    let durationSeconds = CMTimeGetSeconds(asset.duration)
      let midPoint = CMTimeMakeWithSeconds(1, 1)
      imageGenerator.generateCGImagesAsynchronouslyForTimes( [ NSValue(CMTime:midPoint) ], completionHandler: { (requestTime, thumbnail, actualTime, result, error) -> Void in
        
        if let thumbnail = thumbnail {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let thumbnailView = UIImageView(frame: self.mediaView.bounds)
            
            thumbnailView.contentMode = .ScaleAspectFit
            thumbnailView.image = UIImage(CGImage: thumbnail)
            
            self.addSubview(thumbnailView)
            
            let playButtonContainerSize: CGFloat = 70
            
            let playButtonContainer = UIView(frame: CGRectMake(0, 0, playButtonContainerSize, playButtonContainerSize))
            playButtonContainer.layer.cornerRadius = playButtonContainerSize/2;
            playButtonContainer.layer.masksToBounds = true
            playButtonContainer.backgroundColor = UIColor.whiteColor()
            playButtonContainer.alpha = 0.3
            playButtonContainer.center = thumbnailView.center
            
            let playButton = UIImageView(image: self.playButtonIcon)
            
            playButton.center = playButtonContainer.center
            playButton.alpha = 0.6
            
            self.addSubview(playButtonContainer)
            self.addSubview(playButton)
            self.overlayButton = playButton
            
            self.gestureRecognizers?.removeAll()
            let tap = UITapGestureRecognizer(target: self, action: "playButtonPressed")
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            self.addGestureRecognizer(tap)

            self.mediaView.addSubview(self)
          })
        }
      })
    }
  }
  
  func playButtonPressed() {
    self.hidden = true
    player?.playButtonPressed()
  }
      
}