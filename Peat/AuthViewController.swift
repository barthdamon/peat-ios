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
  @IBOutlet weak var firstNameTextField: UITextField!
  
  @IBOutlet weak var loginEmailUsernameTextField: UITextField!
  @IBOutlet weak var loginPasswordTextField: UITextField!
  
  var logoImageViewReference: UIImageView?
  var lifted = false
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
    addGestureRecognizers()
    
    // Do any additional setup after loading the view.
  }
  
  func addGestureRecognizers() {
//    let tapRecognizer = UITapGestureRecognizer(target: self, action: "resignResponders")
//    tapRecognizer.numberOfTapsRequired = 1
//    tapRecognizer.numberOfTouchesRequired = 1
//    self.view.addGestureRecognizer(tapRecognizer)
  }
  
  func resignResponders() {
    self.passwordTextField.resignFirstResponder()
    self.emailTextField.resignFirstResponder()
    self.usernameTextField.resignFirstResponder()
    self.firstNameTextField.resignFirstResponder()
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() where !lifted {
      //      let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
      self.logoImageViewReference = self.logoImageView
      self.logoImageView.removeFromSuperview()
      let height = keyboardSize.height
      self.signUpOptionsView.frame.origin.y -= height
      self.logInOptionsView.frame.origin.y -= height
      lifted = true
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
//    if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
      //      let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
//      let height = keyboardSize.height
//      self.signUpOptionsView.frame.origin.y += height
//      self.logInOptionsView.frame.origin.y -= height
//      if let ref = self.logoImageViewReference {
//        self.view.addSubview(ref)
//        let leftConstraint = NSLayoutConstraint(item: ref, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: ref, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1, constant: 89)
//        let rightConstraint = NSLayoutConstraint(item: ref, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: ref, attribute: NSLayoutAttribute.TrailingMargin, multiplier: 1, constant: 89)
////        let topConstraint = NSLayoutConstraint(item: ref, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
//        let heightConstraint = NSLayoutConstraint(item: ref, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 273)
//        
//        let bottomConstraintSignIn = NSLayoutConstraint(item: self.signUpOptionsView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: ref, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 8)
//        let bottomConstraintLogIn = NSLayoutConstraint(item: self.logInOptionsView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: ref, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 8)
////        let constraints = [heightConstraint, leftConstraint, rightConstraint]
////        ref.addConstraints(constraints)
//        self.logInOptionsView.addConstraint(bottomConstraintLogIn)
//        self.signUpOptionsView.addConstraint(bottomConstraintSignIn)
//        self.view.addConstraints([leftConstraint, rightConstraint])
//      }
//    }
  }
  
  func checkSignUpFields() -> jsonObject? {
    if let name = self.firstNameTextField.text, username = self.usernameTextField.text, email = self.emailTextField.text, password = self.passwordTextField.text where name != "" && username != "" && email != "" && password != "" {
      return ["name" : name, "username" : username, "email" : email, "password" : password]
    } else {
      alertShow(self, alertText: "Error", alertMessage: "Missing Fields")
      return nil
    }
  }
  
  func checkLogInFields() -> jsonObject? {
    if let emailUsername = self.loginEmailUsernameTextField.text, password = self.loginPasswordTextField.text where emailUsername != "" && password != "" {
      return ["emailUsername" : emailUsername, "password" : password]
    } else {
      alertShow(self, alertText: "Error", alertMessage: "Missing Fields")
      return nil
    }
  }
  
  @IBAction func signUpButtonPressed(sender: AnyObject) {
//    resignResponders()
    if let fields = checkSignUpFields() {
      CurrentUser.info.newUser(fields){ (success) in
        if success {
          print("authentication successful")
//          dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.resignResponders()
//            self.dismissViewControllerAnimated(true, completion: nil)
//          })
        } else {
          alertShow(self, alertText: "Error", alertMessage: "Sign Up Unsuccessful")
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
//    resignResponders()
    if let fields = checkLogInFields() {
      CurrentUser.info.logIn(fields){ (success) in
        if success {
          print("authentication successful")
//          dispatch_async(dispatch_get_main_queue(), { () -> Void in
//            self.resignResponders()
//            self.dismissViewControllerAnimated(true, completion: nil)
//          })
        } else {
          alertShow(self, alertText: "Error", alertMessage: "Login Unsuccessful")
        }
      }
    }
  }


}
