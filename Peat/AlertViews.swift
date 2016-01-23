//
//  AlertViews.swift
//  Peat
//
//  Created by Matthew Barth on 1/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


func alertShow(vc: UIViewController, alertText :String, alertMessage :String) {
  let alert = UIAlertController(title: alertText, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
  
  alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
    
    vc.dismissViewControllerAnimated(true, completion: nil)
    
  }))
  //can add another action (maybe cancel, here)
  vc.presentViewController(alert, animated: true, completion: nil)
}
