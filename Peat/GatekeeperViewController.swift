//
//  GatekeeperViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/24/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class GatekeeperViewController: UIViewController {
  
  var authController: AuthViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
      CurrentUser.info.logOut()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "tokenFound", name: "userHasToken", object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "needsLogin", name: "noUserTokenFound", object: nil)
      CurrentUser.info.token()
    }
  
  func tokenFound() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.navigationController?.popToRootViewControllerAnimated(true)
      self.performSegueWithIdentifier("appInit", sender: self)
    })
  }
  
  func needsLogin() {
    self.performSegueWithIdentifier("auth", sender: self)
  }

}
