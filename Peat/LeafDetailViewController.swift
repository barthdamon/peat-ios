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
      if let title = leaf?.abilityTitle {
        self.abilityTitle.text = title
      }
      if let status = self.leaf?.completionStatus {
        self.completionStatusLabel.text = status ? "Completed" : "Incomplete"
      } else {
        self.completionStatusLabel.text = "Incomplete"
      }

      // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  @IBAction func completionButtonPressed(sender: AnyObject) {
    self.completionStatusLabel.text = "Completed"
    leaf?.completionStatus = true
  }

}
