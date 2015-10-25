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

  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var mediaView: UIView!
  
  var videoPath: NSURL?
  var moviePlayer: MPMoviePlayerController?
  var imageDisplay: UIImageView?
  var mediaImage: UIImage?
  var videoOverlayView: UIView?
  var playButtonIcon = UIImage(named: "icon_play_solid")
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func playSelectedMedia() {
    //when video view cell gets tapped it should play the media.
    
  }
  
  func configureMediaViewWithImage(image: UIImage) {
    self.imageDisplay = UIImageView()
    if let display = self.imageDisplay {
      display.frame = self.mediaView.bounds
      display.contentMode = .ScaleAspectFit
      display.image = image
      self.mediaView.addSubview(display)
    }
  }
  
  func configureMediaViewWithVideo(videoPath: NSURL) {
    self.moviePlayer = MPMoviePlayerController()
    if let player = self.moviePlayer {
      player.prepareToPlay()
      player.contentURL = videoPath
      player.view.frame = self.mediaView.bounds
      player.scalingMode = .AspectFit
      player.shouldAutoplay = false
      
//      let rec = UITapGestureRecognizer(target: self, action: "togglePlaystate")
//      rec.numberOfTapsRequired = 1
//      rec.numberOfTouchesRequired = 1
//      mediaView.addGestureRecognizer(rec)
      
      self.mediaView.addSubview(player.view)
      configureThumbnailOverlay()
    }
  }
  
  func configureThumbnailOverlay() {
    let asset = AVURLAsset(URL: self.videoPath!)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform=true
//    let durationSeconds = CMTimeGetSeconds(asset.duration)
    let midPoint = CMTimeMakeWithSeconds(1, 1)
    imageGenerator.generateCGImagesAsynchronouslyForTimes( [ NSValue(CMTime:midPoint) ], completionHandler: {
      (requestTime, thumbnail, actualTime, result, error) -> Void in
      
      if let thumbnail = thumbnail {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.videoOverlayView = UIView(frame: self.mediaView.bounds)
          
          if let overlay = self.videoOverlayView {
            let thumbnailView = UIImageView(frame: self.mediaView.bounds)
            thumbnailView.contentMode = .ScaleAspectFit
            thumbnailView.image = UIImage(CGImage: thumbnail)
            
            overlay.addSubview(thumbnailView)
            
            let playButtonContainerSize: CGFloat = 70
            
            let playButtonContainer = UIView(frame: CGRectMake(0, 0, playButtonContainerSize, playButtonContainerSize))
            playButtonContainer.layer.cornerRadius = playButtonContainerSize/2;
            playButtonContainer.layer.masksToBounds = true
            playButtonContainer.backgroundColor = UIColor.whiteColor()
            playButtonContainer.alpha = 0.3
            playButtonContainer.center = overlay.center
            
            let playButton = UIImageView(image: self.playButtonIcon)
            playButton.center = playButtonContainer.center
            playButton.alpha = 0.6
            
            overlay.addSubview(playButtonContainer)
            overlay.addSubview(playButton)
            
            let tap = UITapGestureRecognizer(target: self, action: "togglePlaystate")
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            overlay.addGestureRecognizer(tap)
            
            self.mediaView.addSubview(overlay)
          }
        })
      }
    })
  }
  
  func togglePlaystate() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.moviePlayer?.play()
      self.videoOverlayView?.hidden = true
      self.videoOverlayView?.removeFromSuperview()
    })
  }
  
  func configureCell(object: MediaObject) {
    if let url = object.url {
      
      if object is PhotoObject {
        if self.mediaImage == nil {
          if let object = object as? PhotoObject {
            if let thumbnail = object.thumbnail {
              configureMediaViewWithImage(thumbnail)
            } else {
              if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
                self.mediaImage = image
                object.thumbnail = image
                configureMediaViewWithImage(image)
              }
            }
          }
        }
        
      } else if object is VideoObject {
        self.videoPath = url
        configureMediaViewWithVideo(url)
      }
      
    }
  }

}
