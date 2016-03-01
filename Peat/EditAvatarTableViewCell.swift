//
//  EditAvatarTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class EditAvatarTableViewCell: UITableViewCell, EditProfileCell  {

  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!
  
  var delegate: EditProfileTableViewController?
  
  func getReuseIdentifier() -> String {
    return "editAvatarCell"
  }
  
  func toggleSaveAndCancel() {
    cancelButton.hidden = !cancelButton.hidden
    saveButton.hidden = !cancelButton.hidden
  }
  
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
  
  @IBAction func saveButtonPressed(sender: AnyObject) {
    CurrentUser.info.model?.updateProfile() { (success) in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.toggleSaveAndCancel()
        NSNotificationCenter.defaultCenter().postNotificationName("userAvatarUpdated", object: nil, userInfo: nil)
      })
    }
  }

  @IBAction func cancelButtonPressed(sender: AnyObject) {
    //remove all the updates to teh user
    CurrentUser.info.model?.newAvatarImage = nil
    toggleSaveAndCancel()
  }
}
