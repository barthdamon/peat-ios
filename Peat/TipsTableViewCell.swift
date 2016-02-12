//
//  TipsTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/11/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class TipsTableViewCell: UITableViewCell {
  
  
  @IBOutlet weak var tipsTitleLabel: UILabel!
  @IBOutlet weak var tipsTextField: UITextView!

  func configureWithTip(text: String) {
    self.tipsTextField.text = text
  }
}
