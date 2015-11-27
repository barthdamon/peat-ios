//
//  LeafDetailViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/5/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class LeafDetailViewController: UIViewController {
  
  var leaf: LeafNode?

  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var playerView: UIView!
  @IBOutlet weak var abilityTitle: UILabel!
  @IBOutlet weak var completionStatusLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureAbilityLayout()
  }

  func configureAbilityLayout() {
    if let title = leaf?.abilityTitle, status = leaf?.completionStatus {
      self.abilityTitle.text = title
    }
    if let status = self.leaf?.completionStatus {
      self.completionStatusLabel.text = status ? "Completed" : "Incomplete"
    } else {
      self.completionStatusLabel.text = "Incomplete"
    }
  }
  
  @IBAction func completionButtonPressed(sender: AnyObject) {
    self.completionStatusLabel.text = "Completed"
    leaf?.completionStatus = true
  }

}
