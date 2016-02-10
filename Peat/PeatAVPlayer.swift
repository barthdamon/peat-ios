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


class PeatAVPlayer: NSObject {
  
  //External
  var playerVC = AVPlayerViewController()
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
    playerVC.showsPlaybackControls = false
    playerVC.view.frame = playerView.bounds
    playerView.addSubview(playerVC.view)
    prepareMediaData()
  }
  
  func stopPlaying() {
    playerVC.player?.pause()
    playerVC.player = nil
  }
  
  func prepareMediaData() {
    var player: AVPlayer?
    if let filePath = mediaObject?.filePath {
      player = AVPlayer(URL: filePath)
    } else if let url = self.url {
      player = AVPlayer(URL: url)
    }
    self.playerVC.player = player
    self.playerVC.showsPlaybackControls = false
  }
  
  func playButtonPressed() {
    self.playerVC.player?.play()
    self.playerVC.showsPlaybackControls = true
  }
  
  // MARK: - Fullscreen transitions
  func checkForResigningFullScreen() {
    let playerWidth = self.playerVC.videoBounds.size.width
    let playerHeight = self.playerVC.videoBounds.size.height
    
    let viewWidth = self.playerVC.view.frame.width
    let viewHeight = self.playerVC.view.frame.height
    
    let result = (playerWidth > viewWidth) && (playerHeight > viewHeight)
    
    if playerWasFullscreen && result == false {
      let value = UIInterfaceOrientation.Portrait.rawValue
      UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    playerWasFullscreen = result
  }
  
  
  
  
}