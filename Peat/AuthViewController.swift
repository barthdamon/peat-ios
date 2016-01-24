//
//  AuthViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/24/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {

  @IBOutlet weak var signUpOptionsView: UIView!
  @IBOutlet weak var logInOptionsView: UIView!
  @IBOutlet weak var logoImageView: UIImageView!
  
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var firstNameTextField: UITextField!
  
  @IBOutlet weak var loginEmailUsernameTextField: UITextField!
  @IBOutlet weak var loginPasswordTextField: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    addGestureRecognizers()
    
    // Do any additional setup after loading the view.
  }
  
  func addGestureRecognizers() {
    let tapRecognizer = UITapGestureRecognizer(target: self, action: "resignResponders")
    tapRecognizer.numberOfTapsRequired = 1
    tapRecognizer.numberOfTouchesRequired = 1
    self.view.addGestureRecognizer(tapRecognizer)
  }
  
  func resignResponders() {
    self.passwordTextField.resignFirstResponder()
    self.emailTextField.resignFirstResponder()
    self.usernameTextField.resignFirstResponder()
    self.lastNameTextField.resignFirstResponder()
    self.firstNameTextField.resignFirstResponder()
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
      //      let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
      self.logoImageView.removeFromSuperview()
      let height = keyboardSize.height
      self.signUpOptionsView.frame.origin.y -= height
      self.logInOptionsView.frame.origin.y -= height
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
      //      let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
      let height = keyboardSize.height
      self.signUpOptionsView.frame.origin.y += height
      self.logInOptionsView.frame.origin.y -= height
      self.logoImageView.hidden = false
    }
  }
  
  func checkSignUpFields() -> jsonObject? {
    if let first = self.firstNameTextField.text, last = self.lastNameTextField.text, username = self.usernameTextField.text, email = self.emailTextField.text, password = self.passwordTextField.text {
      return ["first" : first, "last" : last, "username" : username, "email" : email, "password" : password]
    } else {
      alertShow(self, alertText: "Error", alertMessage: "Missing Fields")
      return nil
    }
  }
  
  @IBAction func signUpButtonPressed(sender: AnyObject) {
    resignResponders()
    if let fields = checkSignUpFields() {
      CurrentUser.info.newUser(fields){ (success) in
        if success {
          self.dismissViewControllerAnimated(true, completion: nil)
        } else {
          alertShow(self, alertText: "Error", alertMessage: "Login Unsuccessful")
        }
      }
    }
  }
  
  @IBAction func switchToLogInButtonPressed(sender: AnyObject) {
    self.signUpOptionsView.hidden = true
    self.logInOptionsView.hidden = false
  }
  
  @IBAction func switchToSignUpButtonPressed(sender: AnyObject) {
    self.logInOptionsView.hidden = true
    self.signUpOptionsView.hidden = false
  }
  
  @IBAction func logInButtonPressed(sender: AnyObject) {
    
  }


}
