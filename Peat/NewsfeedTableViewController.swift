//
//  NewsfeedTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import AWSCore
import AWSS3

class NewsfeedTableViewController: UITableViewController {
  
    var mediaObjects: Array<MediaObject>?
  
    override func viewDidLoad() {
        super.viewDidLoad()
      self.tableView.allowsSelection = false
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "configureMedia", name: "mediaObjectsPopulated", object: nil)
      queryForMediaData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    checkForNewsfeedUpdates()
  }
  
  func checkForNewsfeedUpdates() {
    PeatContentStore.sharedStore.updateNewsfeed() { (res, err) -> () in
      if err != nil {
        print("error updating newsfeed")
      } else {
        print("Newsfeed update complete")
        self.configureMedia()
      }
    }
  }
  
  func queryForMediaData() {
    PeatContentStore.sharedStore.initializeNewsfeed() { (res, err) -> () in
      if err != nil {
        print("error initializing newsfeed")
      } else {
        print("Store fetched Successfuly: \(res)")
        self.configureMedia()
      }
    }
  }
  
  func configureMedia() {
    self.mediaObjects  = PeatContentStore.sharedStore.mediaObjects
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      return self.mediaObjects != nil ? self.mediaObjects!.count : 0
    }
  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MediaTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as! MediaTableViewCell
        if let mediaObjects = self.mediaObjects {
          let object = mediaObjects[indexPath.row]
          cell.configureCell(object)
        }
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
