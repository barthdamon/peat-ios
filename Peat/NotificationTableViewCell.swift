//
//  NotificationTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 3/6/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

  @IBOutlet weak var thumbnailImageView: UIImageView!
  @IBOutlet weak var actionDescriptionLabel: UILabel!
  @IBOutlet weak var notifyingUsernameLabel: UIButton!
  
  var notification: Notification?
  var delegate: MenuTableViewController?
  
  func configureWithNotification(notification: Notification, delegate: MenuTableViewController) {
    self.delegate = delegate
    notification.userNotifying?.generateAvatarImage({ (image) -> () in
      self.thumbnailImageView.image = image
    })
    
    //YOU HAVE THE NOTIFICATION HERE, just do what you gotta do with it! :)
    //OH but repost needs a leaf on it.... :/ EVERYTHING ELSE Though, PAL! :) ;)
    if let type = notification.type {
      var text = ""
      switch type {
      case .Follow:
        text = "Followed You"
      case .Comment:
        text = "Commented on a piece of media"
        if let media = notification.mediaObject, id = CurrentUser.info.model?._id, type = media.mediaType {
          let t = type.rawValue
          if media.uploaderUser_Id == id {
            text = "Commented on a \(t) you uploaded"
          } else if let tagged = media.taggedUser_Ids where tagged.contains(id) {
            text = "Commented on a a \(t) you are tagged in"
          } else {
            text = "Commented on a \(t) you commented on"
          }
        }
      case .Like:
        text = "Liked Media Object"
        if let media = notification.mediaObject, id = CurrentUser.info.model?._id, type = media.mediaType {
          let t = type.rawValue
          if media.uploaderUser_Id == id {
            text = "Liked a \(t) you uploaded"
          } else if let tagged = media.taggedUser_Ids where tagged.contains(id) {
            text = "Liked a \(t) you are tagged in"
          } else {
            text = "Liked a \(t)"
          }
        }
      case .Repost:
        text = "Used media you uploaded"
      case .Tag:
        text = "Tagged you in a media object"
        if let type = notification.mediaObject?.mediaType {
          text = "Tagged you in a \(type.rawValue)"
        }
      case .Witness:
        text = "Witnessed you for an ability"
        if let leaf = notification.leaf, name = leaf.ability?.name {
          text = "Witnessed you for \(name)"
        }
      }
      
      //all the possible messages that can go in the notification (maybe should be done on the server?
      
      self.actionDescriptionLabel.text = text
    }
    
    
    if let username = notification.userNotifying?.username {
      self.notifyingUsernameLabel.setTitle(username, forState: .Normal)
    }
  }

  @IBAction func notifyingUsernameButtonPressed(sender: AnyObject) {
    if let user = notification?.userNotifying {
      self.delegate?.userSelectedFromNotification(user)
    }
  }
}
