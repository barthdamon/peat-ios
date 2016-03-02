//
//  EditProfileFieldTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 3/1/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

enum EditProfileField {
  case Username
  case Email
  case Name
}

class EditProfileFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
  
  var field: EditProfileField?
  var delegate: EditProfileTableViewController?

  @IBOutlet weak var textField: UITextField!
  
  var changesMade: Bool = false
  
  func changesWereMade(changed: Bool) {
    self.changesMade = changed
    delegate?.newChangesMade(self, changed: changed)
  }

  func configureForField(field: EditProfileField) {
    self.field = field
    self.textField.delegate = self
    resetField()
  }
  
  func resetField() {
    if let field = field {
      switch field {
      case .Username:
        self.textField.text = CurrentUser.info.model?.username
      case .Email:
        self.textField.text = CurrentUser.info.model?.email
      case .Name:
        self.textField.text = CurrentUser.info.model?.name
      }
    }
  }
  
  func textFieldShouldClear(textField: UITextField) -> Bool {
    resetField()
    textField.resignFirstResponder()
    changesWereMade(false)
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if let text = textField.text {
      if text != "" {
        changesWereMade(true)
      } else {
        resetField()
        changesWereMade(false)
      }
    }
    textField.resignFirstResponder()
    return true
  }
  
  func commitChanges() {
    if let field = self.field, text = textField.text {
      if text != "" {
        switch field {
        case .Username:
          CurrentUser.info.model?.username = text
        case .Email:
          CurrentUser.info.model?.email = text
        case .Name:
          CurrentUser.info.model?.name = text
        }
      }
    }
  }
  
}
