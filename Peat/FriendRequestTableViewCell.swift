//
//  FriendRequestTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 1/28/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class FriendRequestTableViewCell: UITableViewCell {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  
  var delegate: MenuTableViewController?
  
  override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
  }

  override func setSelected(selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      // Configure the view for the selected state
  }
  
  func configureWithUser(user: User) {
    if let username = user.username, first = user.first, last = user.last {
      self.usernameLabel.text = username
      self.nameLabel.text = "\(first) \(last)"
    }
    user.generateAvatarImage { (image) -> () in
      self.avatarImageView.contentMode = .ScaleAspectFill
      self.avatarImageView.image = image
    }
    
  }

  @IBAction func yesButtonPressed(sender: AnyObject) {
    //confirm friend, on success tell delegate to make cell faded color
  }
  
  @IBAction func noButtonPressed(sender: AnyObject) {
    //remove cell
  }
  
}
