//
//  DefaultCollectionViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 3/8/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class DefaultCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var messageLabel: UILabel!
  
  func configureWithMessage(message: String) {
    self.messageLabel.text = message
  }
    
}
