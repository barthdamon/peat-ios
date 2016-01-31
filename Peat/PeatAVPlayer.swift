//
//  PeatAVPlayer.swift
//  Peat
//
//  Created by Matthew Barth on 12/6/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit


class PeatAVPlayer: AVPlayerViewController {
  
  //External
  var playerView: UIView!
  
  //Internal
  var playerWasFullscreen = false
  
  //Media Data
  var mediaObject: MediaObject?
  var url: NSURL?
  var thumbnail: UIImage?
  
  convenience init(playerView: UIView, media: MediaObject) {
    self.init()
    
    self.playerView = playerView
    self.mediaObject = media
    self.url = media.url
    configureMediaPlayer()
  }
  
  func configureMediaPlayer() {
    showsPlaybackControls = false
    view.frame = playerView.bounds
    playerView.addSubview(self.view)
    prepareMediaData()
  }
  
  func prepareMediaData() {
    if let url = self.url {
      let player = AVPlayer(URL: url)
      self.player = player
      self.showsPlaybackControls = false
    }
  }
  
  func playButtonPressed() {
    self.player?.play()
    self.showsPlaybackControls = true
  }
  
  // MARK: - Fullscreen transitions
  func checkForResigningFullScreen() {
    let playerWidth = self.videoBounds.size.width
    let playerHeight = self.videoBounds.size.height
    
    let viewWidth = self.view.frame.width
    let viewHeight = self.view.frame.height
    
    let result = (playerWidth > viewWidth) && (playerHeight > viewHeight)
    
    if playerWasFullscreen && result == false {
      let value = UIInterfaceOrientation.Portrait.rawValue
      UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    playerWasFullscreen = result
  }
  
  
  
  
}