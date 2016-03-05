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
    if let name = user.name, username = user.username {
      self.usernameLabel.text = username
      self.nameLabel.text = name
    }
    
    user.generateAvatarImage { (image) -> () in
      self.avatarImageView.contentMode = .ScaleAspectFill
      self.avatarImageView.image = image
    }
    self.backgroundColor = UIColor.whiteColor()
    self.user = user
    //do the thumbnail dance, needs to be refactored probly
  }
  
  func setTagged() {
    self.backgroundColor = UIColor.lightGrayColor()
  }

}
