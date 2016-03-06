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
  func configureWithNotification(notification: Notification) {
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
    if let name = notification.userNotifying?.name {
      self.notifyingUsernameLabel.setTitle(name, forState: .Normal)
    }
  }

  @IBAction func notifyingUsernameButtonPressed(sender: AnyObject) {
    
  }
}
