//
//  LoginViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/24/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var emailUsernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
      NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
      NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
//  
//  first: first,
//		last: last,
//		username: username,
//		email: email,
//		password: password,

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func checkFields() -> jsonObject? {
    if let emailUsername = self.emailUsernameTextField.text, password = self.passwordTextField.text {
      return ["emailUsername" : emailUsername, "password" : password]
    } else {
      alertShow(self, alertText: "Error", alertMessage: "Missing Fields")
      return nil
    }
  }

  @IBAction func signUpButtonPressed(sender: AnyObject) {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  @IBAction func logInButtonPressed(sender: AnyObject) {
    if let fields = checkFields() {
      CurrentUser.info.logIn(fields){ (success) in
        if success {
          self.dismissViewControllerAnimated(true, completion: nil)
        } else {
          alertShow(self, alertText: "Error", alertMessage: "Login Unsuccessful")
        }
      }
    }
    
  }
}
