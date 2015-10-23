//
//  UserSearchResultTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 10/23/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class UserSearchResultTableViewCell: UITableViewCell {

  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
