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


class MediaTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
  
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var commentTableView: UITableView!
  
  var media: MediaObject?
  
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
    self.selectionStyle = UITableViewCellSelectionStyle.None
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
  
//  func togglePlaystate() {
//    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//      self.moviePlayer?.play()
//      self.videoOverlayView?.hidden = true
//      self.videoOverlayView?.removeFromSuperview()
//    })
//  }
  
//  func configureCell(object: MediaObject) {
//    if let url = object.url {
//
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
//  }

  
  //MARK: Comment Section
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    
//    var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cellID") as? UITableViewCell
//    if(cell == nil) {
//      cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cellID")
//    }
//    cell!.textLabel.text = dataArr[indexPath.row]
//    return cell!
    let cell = UITableViewCell()
    return cell
  }
  
}
