//
//  GatekeeperViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/24/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class GatekeeperViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "tokenFound", name: "userHasToken", object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "needsLogin", name: "noUserTokenFound", object: nil)
      CurrentUser.info.token()
    }
  
  func tokenFound() {
    self.performSegueWithIdentifier("appInit", sender: self)
  }
  
  func needsLogin() {
    self.performSegueWithIdentifier("auth", sender: self)
  }

}
