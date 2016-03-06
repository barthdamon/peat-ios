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
    if let type = notification.type {
      var text = ""
      switch type {
      case .Follow:
        text = "Followed You"
      default:
        text = "Notified You"
        break
      }
      self.actionDescriptionLabel.text = text
    }
    if let name = notification.userNotifying?.name, username = notification.userNotifying?.username {
      self.notifyingUsernameLabel.setTitle(username, forState: .Normal)
    }
  }

  @IBAction func notifyingUsernameButtonPressed(sender: AnyObject) {
    if let user = notification?.userNotifying {
      self.delegate?.userSelectedFromNotification(user)
    }
  }
}
