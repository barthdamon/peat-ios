//
//  TagUserTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class TagUserTableViewCell: UITableViewCell {
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  
  var user: User?
  
  func configureWithUser(user: User) {
    if let first = user.first, last = user.last, username = user.username {
      self.usernameLabel.text = username
      self.nameLabel.text = "\(first) \(last)"
    }
    
    user.generateAvatarImage { (image) -> () in
      self.avatarImageView.contentMode = .ScaleAspectFill
      self.avatarImageView.image = image
    }
    self.user = user
    //do the thumbnail dance, needs to be refactored probly
  }

}
