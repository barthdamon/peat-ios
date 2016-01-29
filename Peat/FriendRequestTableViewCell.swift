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
  @IBOutlet weak var yesButton: UIButton!
  @IBOutlet weak var noButton: UIButton!
  
  var user: User?
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
    self.user = user
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
    if let user = user, id = user._id {
      PeatSocialMediator.sharedMediator.confirmFriendRequest(id, callback: { (success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.backgroundColor = UIColor.greenColor()
            self.yesButton.enabled = false
            self.noButton.enabled = false
          })
        } else {
          print("Error confirming friend")
        }
      })
    }
    //confirm friend, on success tell delegate to make cell faded color
  }
  
  @IBAction func noButtonPressed(sender: AnyObject) {
    if let user = user, id = user._id {
      PeatSocialMediator.sharedMediator.destroyFriendRequest(id, callback: { (success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.backgroundColor = UIColor.redColor()
            self.yesButton.enabled = false
            self.noButton.enabled = false
          })
        } else {
          print("Error destroying friend")
        }
      })
    }
  }
  
}
