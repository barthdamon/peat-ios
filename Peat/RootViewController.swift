//
//  RootViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/8/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

public var globalMainContainer: UIView?

class RootViewController: UIViewController {

  @IBOutlet weak var mainViewContainer: UIView!
  @IBOutlet weak var menuWidthConstraint: NSLayoutConstraint!
  var homeViewController: HomeViewController?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      let windowWidth = self.view.frame.width
      menuWidthConstraint.constant = windowWidth * 0.8
      
      globalMainContainer = mainViewContainer
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "homeViewEmbed" {
        print("homeViewEmbed")
        if let navCon = segue.destinationViewController as? UINavigationController,
          vc = navCon.topViewController as? HomeViewController {
            self.homeViewController = vc
        }
      } else if segue.identifier == "menuEmbed" {
        print("homeMenuEmbed")
        if let navCon = segue.destinationViewController as? UINavigationController,
          vc = navCon.topViewController as? MenuTableViewController {
            vc.rootController = self
        }
      }
    }
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
