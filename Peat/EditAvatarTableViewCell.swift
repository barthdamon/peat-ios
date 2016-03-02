//
//  EditAvatarTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class EditAvatarTableViewCell: UITableViewCell, EditProfileCell  {
  
  @IBOutlet weak var actionButton: UIButton!
  @IBOutlet weak var avatarImageView: UIImageView!
  
  var delegate: EditProfileTableViewController?
  var avatar: UIImage? {
    didSet {
      delegate?.newChangesMade(self, changed: true)
      self.avatarImageView.image = avatar
      toggleAction()
    }
  }
  
  func getReuseIdentifier() -> String {
    return "editAvatarCell"
  }
  
  func toggleAction() {
    if self.actionButton.titleLabel?.text == "Change" {
      self.actionButton.setTitle("Cancel", forState: .Normal)
    } else {
      self.actionButton.setTitle("Change", forState: .Normal)
    }
  }
  
  func configureForCurrentUser() {
    CurrentUser.info.model?.generateAvatarImage({ (image) -> () in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.avatarImageView.image = image
      })
    })
  }

  @IBAction func actionButtonPressed(sender: AnyObject) {
    if actionButton.titleLabel?.text == "Change" {
      delegate?.chooseNewAvatarSelected()
    } else {
      //remove all the updates to teh user
      configureForCurrentUser()
      delegate?.newChangesMade(self, changed: false)
      toggleAction()
    }
  }
  
  func commitChanges() {
    if let avatar = avatar {
      CurrentUser.info.addAvatarImage(avatar)
      toggleAction()
    }
  }
  
}
