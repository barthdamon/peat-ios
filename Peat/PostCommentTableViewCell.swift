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

  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var commentField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  @IBAction func sendButtonPressed(sender: AnyObject) {
  }

}
