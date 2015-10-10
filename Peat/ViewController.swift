//
//  ViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/10/15.
//  Copyright (c) 2015 Matthew Barth. All rights reserved.
//

import UIKit
import KeychainSwift
import MediaPlayer
import AVFoundation

class ViewController: UIViewController {
  
  var moviePlayer : MPMoviePlayerController?
  
  
  
  var authToken :Dictionary<String, AnyObject>?
  
  let keychain = KeychainSwift()
  var videoPath: NSURL?

  @IBOutlet weak var playerView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()

    queryForMediaData()
    // Do any additional setup after loading the view, typically from a nib.
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMedia", name: "videoObjectsPopulated", object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)

  }
  
  func queryForMediaData() {
    PeatContentStore.sharedStore.initializeNewsfeed() { (res, err) -> () in
      if err != nil {
        print("error fetching the store")
      } else {
        print("Store fetched Successfuly: \(res)")
        PeatContentStore.sharedStore.downloadVideoContent()
      }
    }
  }
  
  func showMedia() {
    if PeatContentStore.sharedStore.mediaObjects.count > 0 {
      let media = PeatContentStore.sharedStore.mediaObjects[0]
//      if media is PhotoObject {
//        if let photoObject = media as? PhotoObject {
//          if let image = photoObject.thumbnail {
//            self.imageView.image = image
//          }
//        }
//      } else
        if media is VideoObject {
          print("video object recieved")
          if let videoObject = media as? VideoObject {
//            if let image = videoObject.thumbnail {
              if let url = videoObject.videoFilePath {
//                self.imageView.image = image
                self.videoPath = url
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                  self.playVideo()
                })
              }
//            }
          }
        }
        //deal with the video
    } else {
      print("Image fed up")
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func playVideo() {
    configureMediaPlayer()
      
    if let url = self.videoPath {
      if let player = self.moviePlayer {
        player.prepareToPlay()
        player.contentURL = url
      }
    }
  }

  
  func configureMediaPlayer() {
    
    self.moviePlayer = MPMoviePlayerController()
    if let player = self.moviePlayer {
      player.prepareToPlay()
      player.view.frame = self.playerView.bounds
      player.scalingMode = .AspectFit
      player.shouldAutoplay = false
      self.playerView.addSubview(player.view)
      player.play()
    }

//    configureThumbnailOverlay()
//    
//    self.playerView.bringSubviewToFront(self.liveStreamHeaderView)
  }

  
  func saveTokenToKeychain(json :Dictionary<String,AnyObject>) {
    
    if let tokenExpiry = json["authtoken_expiry"] as? String {
      self.keychain.set(tokenExpiry, forKey: "authToken_expiry")
    }
    
    if let token = json["api_authtoken"] as? String {
      self.keychain.set(token, forKey: "api_authToken")
    }
    
  }
  
  
  func sendToken(sender: AnyObject) {
    APIService.sharedService.post(["params":["auth_type":"Basic","user":["email":"mbmattbarth@gmail.com","password":"mattdamon7"]]], authType: HTTPRequestAuthType.Basic, url: "login") { (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
      } else {
        if let json = res as? Dictionary<String, AnyObject> {
          print(json)
          if let token = json["api_authtoken"] as? String {
            APIService.sharedService.authToken = token
          }
        }
      }
    }
  }
  
  
  
}
