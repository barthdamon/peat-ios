//
//  MediaCellHeaderView.swift
//  Peat
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class MediaCellHeaderView: UIView {

  @IBOutlet weak var usernameButton: UIButton!
  @IBOutlet weak var subtitleTextLabel: UILabel!
  @IBOutlet weak var subtitleUsernameButton: UIButton!
  @IBOutlet weak var userThumbnailView: UIImageView!
  
  var media: MediaObject?
  var primaryUser: User?
  
  func configureForUserLeaf(media: MediaObject, primaryUser: User?) {
    self.primaryUser = primaryUser
    self.media = media
    
    //Looking at a users leaf:
    if let primaryUser = primaryUser, name = primaryUser.username {
      self.usernameButton.setTitle(name, forState: .Normal)
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
  
  func configureForLeafFeed(media: MediaObject) {
    self.media = media
    
    if let taggedUsers = media.taggedUsers {
      do {
        //TODO, make a list of all the users that user is following
        let main = try taggedUsers.lookup(UInt(0))
        self.primaryUser = main
        if let name = main.username {
          self.usernameButton.setTitle(name, forState: .Normal)
        }
      }
      catch {
        print("tagged user not found")
      }
    } else {
      self.usernameButton.setTitle("", forState: .Normal)
      self.usernameButton.enabled = false
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
  
  func configureForNewsfeed(media: MediaObject) {
    self.media = media
  
    if let taggedUsers = media.taggedUsers, following = CurrentUser.info.model?.following {
      var taggedFollowing: Array<User> = []
      taggedUsers.forEach({ (user) -> () in
        following.forEach({ (follow) -> () in
          if let user_Id = user._id, follow_Id = follow._id where user_Id == follow_Id {
            taggedFollowing.append(user)
          }
        })
      })
      do {
        //TODO, make a list of all the users that user is following
        let main = try taggedFollowing.lookup(UInt(0))
        self.primaryUser = main
        if let name = main.username {
          self.usernameButton.setTitle(name, forState: .Normal)
        }
      }
      catch {
        print("followed user not found")
      }
    } else {
      self.usernameButton.setTitle("", forState: .Normal)
      self.usernameButton.enabled = false
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
    //show the users profile
  }
  
  @IBAction func subtitleUsernameButtonPressed(sender: AnyObject) {
    //show the users profile
  }

}
