//
//  CommentsTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 12/3/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

  @IBOutlet weak var userLabel: UILabel!
  @IBOutlet weak var commentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
