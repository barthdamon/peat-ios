//
//  ProfileLoadViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/7/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class ProfileLoadViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegueWithIdentifier("currentUserProfileShow", sender: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
