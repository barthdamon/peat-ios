//
//  WitnessRequestViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/6/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class WitnessRequestViewController: UIViewController {
  
  var leaf: Leaf?
  var viewing: User?
  

  @IBOutlet weak var messageTextField: UITextField!
  @IBOutlet weak var locationTextField: UITextField!
  
  @IBOutlet weak var submitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  @IBAction func submitButtonPressed(sender: AnyObject) {
    let params = [
      "leafId" : "",
      "witnessId" : "",
      "witnessed_Id" : "",
    ]
    PeatSocialMediator.sharedMediator.sendWitnessRequest(params) { (success) -> () in
      if success {
        print("SUCECSS, show something")
      } else {
        print("FAILURE, still show something")
      }
    }
  }

}
