////
////  UserSearchResultTableViewCell.swift
////  Peat
////
////  Created by Matthew Barth on 10/23/15.
////  Copyright © 2015 Matthew Barth. All rights reserved.
////
//
//import UIKit
//
//class UserSearchResultTableViewCell: UITableViewCell {
//  
//  var foundUser: User?
//
//  @IBOutlet weak var addButton: UIButton!
//  @IBOutlet weak var usernameLabel: UILabel!
//  @IBOutlet weak var nameLabel: UILabel!
//  
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
////      if let user = foundUser {
////        print("USER REGISTERED")
////        if user.isFriend {
////          self.addButton.hidden = true
////          self.usernameLabel.textColor = UIColor.lightGrayColor()
////          self.nameLabel.textColor = UIColor.lightGrayColor()
////        }
////      }
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//
//  @IBAction func addButtonPressed(sender: AnyObject) {
//    if let user = foundUser, id = user._id {
//      PeatSocialMediator.sharedMediator.putFriendRelation(id) { (res, err) in
//        if let e = err {
//          print("error adding friend: \(e)")
//        } else {
//          print("friend added")
//          self.addButton.hidden = true
//          self.backgroundColor = UIColor.greenColor()
//        }
//      }
//    }
//  }
//}
