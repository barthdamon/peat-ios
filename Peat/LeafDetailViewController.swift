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
        if let selectedMedia = currentMedia, url = selectedMedia.url {
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
          }
        }
      }
    }
  }
    
//      if object is PhotoObject {
//        if self.mediaImage == nil {
//          if let object = object as? PhotoObject {
//            if let thumbnail = object.thumbnail {
//              configureMediaViewWithImage(thumbnail)
//            } else {
//              if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
//                self.mediaImage = image
//                object.thumbnail = image
//                configureMediaViewWithImage(image)
//              }
//            }
//          }
//        }
//        
//      } else if object is VideoObject {
//        self.videoPath = url
//        configureMediaViewWithVideo(url)
//      }
//      
//    }
  
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
  
//  func configureMediaViewWithVideo(videoPath: NSURL) {
//    self.moviePlayer = MPMoviePlayerController()
//    if let player = self.moviePlayer {
//      player.prepareToPlay()
//      player.contentURL = videoPath
//      player.view.frame = self.mediaView.bounds
//      player.scalingMode = .AspectFit
//      player.shouldAutoplay = false
//      
//      //      let rec = UITapGestureRecognizer(target: self, action: "togglePlaystate")
//      //      rec.numberOfTapsRequired = 1
//      //      rec.numberOfTouchesRequired = 1
//      //      mediaView.addGestureRecognizer(rec)
//      
//      self.mediaView.addSubview(player.view)
//      configureThumbnailOverlay()
//    }
//  }
  
//  func configureThumbnailOverlay() {
//    let asset = AVURLAsset(URL: self.videoPath!)
//    let imageGenerator = AVAssetImageGenerator(asset: asset)
//    imageGenerator.appliesPreferredTrackTransform=true
//    //    let durationSeconds = CMTimeGetSeconds(asset.duration)
//    let midPoint = CMTimeMakeWithSeconds(1, 1)
//    imageGenerator.generateCGImagesAsynchronouslyForTimes( [ NSValue(CMTime:midPoint) ], completionHandler: {
//      (requestTime, thumbnail, actualTime, result, error) -> Void in
//      
//      if let thumbnail = thumbnail {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//          self.videoOverlayView = UIView(frame: self.mediaView.bounds)
//          
//          if let overlay = self.videoOverlayView {
//            let thumbnailView = UIImageView(frame: self.mediaView.bounds)
//            thumbnailView.contentMode = .ScaleAspectFit
//            thumbnailView.image = UIImage(CGImage: thumbnail)
//            
//            overlay.addSubview(thumbnailView)
//            
//            let playButtonContainerSize: CGFloat = 70
//            
//            let playButtonContainer = UIView(frame: CGRectMake(0, 0, playButtonContainerSize, playButtonContainerSize))
//            playButtonContainer.layer.cornerRadius = playButtonContainerSize/2;
//            playButtonContainer.layer.masksToBounds = true
//            playButtonContainer.backgroundColor = UIColor.whiteColor()
//            playButtonContainer.alpha = 0.3
//            playButtonContainer.center = overlay.center
//            
//            let playButton = UIImageView(image: self.playButtonIcon)
//            playButton.center = playButtonContainer.center
//            playButton.alpha = 0.6
//            
//            overlay.addSubview(playButtonContainer)
//            overlay.addSubview(playButton)
//            
//            let tap = UITapGestureRecognizer(target: self, action: "togglePlaystate")
//            tap.numberOfTapsRequired = 1
//            tap.numberOfTouchesRequired = 1
//            overlay.addGestureRecognizer(tap)
//            
//            self.mediaView.addSubview(overlay)
//          }
//        })
//      }
//    })
//  }
  
  @IBAction func completionButtonPressed(sender: AnyObject) {
    self.completionStatusLabel.text = "Completed"
    leaf?.completionStatus = true
  }

}
