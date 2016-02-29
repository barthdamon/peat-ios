//
//  MediaCellHeaderView.swift
//  Peat
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

protocol MediaHeaderCellDelegate {
  func showTaggedUsers(users: Array<User>, media: MediaObject)
  func showUploaderUser(user: User, media: MediaObject)
}

class MediaCellHeaderView: UIView {

  @IBOutlet weak var usernameButton: UIButton!
  @IBOutlet weak var subtitleTextLabel: UILabel!
  @IBOutlet weak var subtitleUsernameButton: UIButton!
  @IBOutlet weak var userThumbnailView: UIImageView!
  
  
  var media: MediaObject?
  var primaryUser: User?
  
  var delegate: MediaHeaderCellDelegate?
  
  
  var taggedUsers: Array<User>?
  var uploaderUser: User?
  
  func configureForMedia(media: MediaObject, primaryUser: User?, delegate: MediaHeaderCellDelegate) {
    self.primaryUser = primaryUser
    self.media = media
    self.uploaderUser = media.uploaderUser
    self.delegate = delegate
    
    //Looking at a users leaf:
    self.taggedUsers = []
    var otherNames = ""
    if let primaryUser = primaryUser, name = primaryUser.username {
      self.taggedUsers!.append(primaryUser)
      otherNames = "\(name)"
    }
    if let tagged = media.taggedUsers {
      tagged.forEach({ (user) -> () in
        self.taggedUsers!.append(user)
        if let taggedName = user.username {
          otherNames = "otherNames, \(taggedName)"
        }
      })
    self.usernameButton.setTitle(otherNames, forState: .Normal)
    }
    
    if let uploaderUser = media.uploaderUser, username = uploaderUser.username,
      datePosted = media.datePosted {
        subtitleTextLabel.text = "\(datePosted.shortString) by"
        subtitleUsernameButton.setTitle(username, forState: .Normal)
    }
    
    //check for if there is a userOnLeaf
    self.primaryUser?.generateAvatarImage({ (image) -> () in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.userThumbnailView.image = image
      })
    })
  }
  
  @IBAction func usernameButtonPressed(sender: AnyObject) {
    if let users = self.taggedUsers, media = self.media {
      self.delegate?.showTaggedUsers(users, media: media)
      //show the list of all tagged users
    }
  }
  
  @IBAction func subtitleUsernameButtonPressed(sender: AnyObject) {
    if let user = self.uploaderUser, media = self.media {
      self.delegate?.showUploaderUser(user, media: media)
    }
    //show the uplaoder use profile
  }

}
