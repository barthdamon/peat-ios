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
  
  //primary user is either the friend in the newsfeed, or user whos leaf the media header view is on.
  func configureForMedia(media: MediaObject, primaryUser: User?) {
    
    if let uploaderUser = media.uploaderUser, username = uploaderUser.username {
      subtitleUsernameButton.setTitle(username, forState: .Normal)
    }
    
    if let _ = media.timestamp {
      subtitleTextLabel.text = "Posted DATE by"
    }
    
    //check for if there is a userOnLeaf
    if let tagged = media.taggedUsers {
      do {
        let user = try tagged.lookup( UInt(0) )
        if let username = user.username {
          usernameButton.setTitle(username, forState: .Normal)
        }
        user.generateAvatarImage({ (image) -> () in
          dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.userThumbnailView.image = image
          })
        })
      }
      catch {
        print("empty tagged users")
      }
    }
  }
  
  @IBAction func usernameButtonPressed(sender: AnyObject) {
    //show the users profile
  }
  
  @IBAction func subtitleUsernameButtonPressed(sender: AnyObject) {
    //show the users profile
  }

}
