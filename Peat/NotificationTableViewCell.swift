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
    
  }

  @IBAction func notifyingUsernameButtonPressed(sender: AnyObject) {
    
  }
}
