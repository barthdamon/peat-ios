//
//  SearchTableViewCell.swift
//  Peat
//
//  Created by Matthew Barth on 2/15/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
  func configureTextFieldElements(textField: UITextField) {
    
    let iconSize: CGFloat = 18
    
    let container = UIView(frame: CGRectMake(4, 0, 28, 18))
    let magnifyView = UIImageView(frame: CGRectMake(0, 0, iconSize, iconSize))
    magnifyView.image = UIImage(named: "magnify")
    magnifyView.image = magnifyView.image!.imageWithRenderingMode(.AlwaysTemplate)
    magnifyView.tintColor = .lightGrayColor()
    
    container.addSubview(magnifyView)
    magnifyView.center.x += 4
    //    magnifyView.center.y -= 4
    
    textField.leftView = container
    
    textField.leftViewMode = .Always
  }
  
  
  func configureForSearch( ) {
    //    cell.textLabel?.text = "Search"
    //    cell.imageView?.image = UIImage(named: "magnify")
    let width = self.contentView.frame.width
    let searchField = UITextField(frame: CGRectMake(16, 8, width, 30))
    searchField.backgroundColor = UIColor.whiteColor()
    searchField.placeholder = "Search"
    searchField.returnKeyType = .Search
    searchField.userInteractionEnabled = false
    searchField.tag = 999
    
    configureTextFieldElements(searchField)
    
    self.contentView.addSubview(searchField)
    
    self.accessoryType = .None
    self.selectionStyle = .None
    self.backgroundColor = UIColor.clearColor()
  }
    
}
