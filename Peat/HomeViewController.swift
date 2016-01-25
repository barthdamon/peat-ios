//
//  HomeViewController.swift
//  Peat
//
//  Created by Matthew Barth on 11/8/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, ViewControllerWithMenu {
  
  var containerView: UIView?
  var menuCloseTapGesture: UITapGestureRecognizer?
  var sidebarClient: SideMenuClient?

    override func viewDidLoad() {
        super.viewDidLoad()
      
      // Do any additional setup after loading the view.
      initializeSidebar()
      configureNavBar()
      configureMenuSwipes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  
    //MARK: Sidebar
    func initializeSidebar() {
      self.sidebarClient = SideMenuClient(clientController: self, tabBar: self.tabBarController)
    }
  
    func configureNavBar() {
      sidebarClient?.configureNavBar()
    }
    
    func configureMenuSwipes() {
      sidebarClient?.configureMenuSwipes()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  
  
  @IBAction func testButtonClick(sender: AnyObject) {
    self.performSegueWithIdentifier("showMainViewController", sender: self)
  }
  

}
