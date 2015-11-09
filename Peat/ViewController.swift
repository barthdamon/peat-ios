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

class ViewController: UIViewController, ViewControllerWithMenu {
  
  var moviePlayer : MPMoviePlayerController?
  var authToken :Dictionary<String, AnyObject>?
  
  let keychain = KeychainSwift()
  var videoPath: NSURL?
  var sidebarClient: SideMenuClient?

  @IBOutlet weak var playerView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initializeSidebar()
    configureMenuSwipes()
    configureNavBar()
    // Do any additional setup after loading the view, typically from a nib.
//    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMedia", name: "videoObjectsPopulated", object: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
//    queryForMediaData()
  }
  
  func queryForMediaData() {
    PeatContentStore.sharedStore.initializeNewsfeed() { (res, err) -> () in
      if err != nil {
        print("error fetching the store")
      } else {
        print("Store fetched Successfuly: \(res)")
        
      }
    }
  }
  
  func showMedia() {
    if let media = PeatContentStore.sharedStore.mediaObjects?[1] {
      if let url = media.url {
        if media is PhotoObject {
          if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
              self.imageView.image = image
            })
          }
        } else if media is VideoObject {
          self.videoPath = url
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.playVideo()
          })
        }
      }
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
  
  //MARK: Sidebar
  func initializeSidebar() {
    self.sidebarClient = SideMenuClient(clientController: self)
  }
  
  func configureNavBar() {
    sidebarClient?.configureNavBar()
  }
  
  func configureMenuSwipes() {
    sidebarClient?.configureMenuSwipes()
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
