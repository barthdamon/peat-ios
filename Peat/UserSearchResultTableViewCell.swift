//
//  UserSearchResultTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 10/23/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class UserSearchResultTableViewCell: UITableViewCell {
  
  var user: User?

  @IBOutlet weak var tagButton: UIButton!
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      user?.generateAvatarImage({ (image) -> () in
        self.avatarImageView.image = image
      })
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  @IBAction func tagButtonPressed(sender: AnyObject) {
    //i dunno fucking tell the delegate
//    self.delegate?.uploadingForUser(user)
  }

  @IBAction func addButtonPressed(sender: AnyObject) {
    if let user = user, id = user._id {
      PeatSocialMediator.sharedMediator.createFollow(id, callback: { (success) -> () in
        if success {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.addButton.backgroundColor = UIColor.greenColor()
          })
        } else {
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.addButton.backgroundColor = UIColor.redColor()
          })
        }
      })
    }
  }
  
}
