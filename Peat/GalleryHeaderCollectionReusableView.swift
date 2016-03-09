//
//  GalleryHeaderCollectionReusableView.swift
//  Peat
//
//  Created by Matthew Barth on 3/8/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit



class GalleryHeaderCollectionReusableView: UICollectionReusableView {
  @IBOutlet weak var sectionHeaderLabel: UILabel!
  
  
  func configureWithTitle(title: String) {
    sectionHeaderLabel.text = title
  }
}
