//
//  EditAvatarTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class EditAvatarTableViewCell: UITableViewCell {

  @IBOutlet weak var avatarImageView: UIImageView!
  
  var delegate: EditProfileTableViewController?
  
  
  func configureForCurrentUser() {
    CurrentUser.info.model?.generateAvatarImage({ (image) -> () in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.avatarImageView.image = image
      })
    })
  }

  
  @IBAction func chooseButtonPressed(sender: AnyObject) {
    delegate?.chooseNewAvatarSelected()
  }

}
