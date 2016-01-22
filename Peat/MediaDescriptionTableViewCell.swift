//
//  MediaDescriptionTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 12/3/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class MediaDescriptionTableViewCell: UITableViewCell {
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var userLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
