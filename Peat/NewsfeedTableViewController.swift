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
  
    var mediaObjects: Array<PhotoObject>?
    var imageArray: Array<UIImage> = []
    var userArray: Array<String> = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "configureMedia", name: "mediaObjectsPopulated", object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
      queryForMediaData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func queryForMediaData() {
    PeatContentStore.sharedStore.initializeNewsfeed() { (res, err) -> () in
      if err != nil {
        print("error fetching the store")
      } else {
        print("Store fetched Successfuly: \(res)")
        PeatContentStore.sharedStore.generateMediaThumbnails()
      }
    }
  }
  
  func configureMedia() {
    self.mediaObjects  = PeatContentStore.sharedStore.photoObjects
    mediaObjects?.forEach({ (object: PhotoObject) in
      // TODO: if it is an image, get the thumbnail, ect
      self.imageArray.append(object.thumbnail!)
      self.userArray.append(object.user!)
    })
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
        return imageArray.count
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MediaTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("mediaCell", forIndexPath: indexPath) as! MediaTableViewCell
        cell.mediaView.image = imageArray[indexPath.row]
        cell.userLabel.text = userArray[indexPath.row]
      
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
