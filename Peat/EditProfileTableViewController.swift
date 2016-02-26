//
//  EditProfileTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
  
  var mediaObject: MediaObject?
  var image: UIImage? {
    didSet {
      CurrentUser.info.addAvatarImage(image!)
      self.tableView.reloadData()
    }
  }

    override func viewDidLoad() {
      super.viewDidLoad()
      let button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "saveButtonPressed")
      self.navigationController?.navigationItem.rightBarButtonItem = button
    }
  
    func saveButtonPressed() {
      
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
  
  func chooseNewAvatarSelected() {
    displayCameraControl()
  }

}




//MARK: Media Upload Methods
extension EditProfileTableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func displayCameraControl() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    
    //Allows for video and images:
//    if let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePickerController.sourceType) {
//      imagePickerController.mediaTypes = availableMediaTypes
//    }
//    
    self.navigationController?.presentViewController(imagePickerController, animated: false, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    // dismiss the image picker controller window
    self.dismissViewControllerAnimated(true, completion: {
      //Determine if Video or Image Data
//      if (info[UIImagePickerControllerEditedImage] == nil && info[UIImagePickerControllerOriginalImage] == nil) {
//        //VIDEO
//        self.videoPath = info[UIImagePickerControllerMediaURL] as? NSURL
//        self.mediaType = .Video
//        self.mediaObject?.filePath = self.videoPath
//        
//      } else {
      //upload the image, then put that mediaId as the avatar image
        if picker.allowsEditing {
          self.image = info[UIImagePickerControllerEditedImage] as? UIImage
//          self.mediaObject?.thumbnail = self.image
        } else {
          self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//          self.mediaObject?.thumbnail = self.image
        }
      //Need to put the image on the current user, but unsaved. Then reload table view.
      //Then When saving the users profile check the avatar image if it needs publishing. If it does, post it first.....
//      }
    })
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(false, completion: {
//      self.dismissSelf(false)
    })
  }
}
