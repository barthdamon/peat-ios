//
//  PostCommentTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 1/21/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class PostCommentTableViewCell: UITableViewCell {
  
  var media: MediaObject?
  var delegate: CommentsTableViewController?

  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var commentField: UITextField!

  @IBAction func sendButtonPressed(sender: AnyObject) {
    if let text = self.commentField.text, media = media, mediaId = media.mediaId, user = CurrentUser.info.model {
      let comment = Comment.newComment(text, mediaId: mediaId, user: user)
      PeatSocialMediator.sharedMediator.newComment(comment) { (success) in
        guard success else { /*show error*/return }
        //add a new comment to ui
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.media?.newComment(comment)
          self.delegate?.updateCommentCount()
          self.commentField.text = ""
          self.commentField.resignFirstResponder()
        })
        //reload table View
      }
    }
  }

}
