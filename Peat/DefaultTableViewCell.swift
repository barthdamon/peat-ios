//
//  DefaultTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 3/6/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {

  @IBOutlet weak var messageLabel: UILabel!
  
//  convenience init(message: String) {
//    self.init()
//    self.messageLabel.text = message
//  }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
  
  func configureWithMessage(message: String) {
    self.messageLabel.text = message
    self.selectionStyle = .None
  }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
