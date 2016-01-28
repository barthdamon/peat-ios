//
//  GatekeeperViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/24/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit
import KeychainSwift

class GatekeeperViewController: UIViewController {
  
  //NOTE: ONLY FOR DEBUGGING
  var keychain = KeychainSwift()
  
  var authController: AuthViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
//      keychain.delete("api_authtoken")
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "logOutUser", name: "userLoggedOut", object: nil)
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
    UIView.setAnimationsEnabled(false)
    self.performSegueWithIdentifier("auth", sender: self)
    UIView.setAnimationsEnabled(true)
  }
  
  func logOutUser() {
    self.navigationController?.popToRootViewControllerAnimated(false)
    self.performSegueWithIdentifier("auth", sender: self)
  }

}
