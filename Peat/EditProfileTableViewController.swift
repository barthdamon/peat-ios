//
//  EditProfileTableViewController.swift
//  Peat
//
//  Created by Matthew Barth on 2/25/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

protocol EditProfileCell {
  func getReuseIdentifier() -> String
}

class EditProfileTableViewController: UITableViewController {
  
  var mediaObject: MediaObject?
  
  var changedCells: Set<UITableViewCell> = []
  
  func newChangesMade(cell: UITableViewCell, changed: Bool) {
    if changed {
      changedCells.insert(cell)
    } else {
      changedCells.remove(cell)
    }
    if changedCells.count > 0 {
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveButtonPressed")
    } else {
      self.navigationItem.rightBarButtonItem = nil
    }
  }
  
  var editFields: Array<EditProfileField> = [.Name, .Username, .Email]
  
  var avatarEditCell: EditAvatarTableViewCell?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureNavBar()
  }
  
  func configureNavBar() {
    self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)
    self.view.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.navigationBarHidden = false
  }
  
  override func viewWillDisappear(animated: Bool) {
    self.navigationController?.navigationBarHidden = true
  }
  
  func reload() {
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.tableView.reloadData()
    })
  }
  
  func dismissSelf() {
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return editFields.count + 1
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return indexPath.row == 0 ? 93 : 53
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    switch indexPath.row {
    case 0:
      if let cell = tableView.dequeueReusableCellWithIdentifier("editAvatarCell", forIndexPath: indexPath) as? EditAvatarTableViewCell {
        cell.delegate = self
        cell.configureForCurrentUser()
        self.avatarEditCell = cell
        return cell
      }
    default:
      if let cell = tableView.dequeueReusableCellWithIdentifier("editFieldCell", forIndexPath: indexPath) as? EditProfileFieldTableViewCell {
        cell.delegate = self
        do {
          let field = try self.editFields.lookup(UInt(indexPath.row - 1))
          cell.configureForField(field)
        } catch {
          print("Wrong number of edit profile fields")
        }
        return cell
      }
    }
    // Configure the cell...
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
  
  func chooseNewAvatarSelected() {
    displayCameraControl()
  }
  
  func saveButtonPressed() {
    for cell in changedCells {
      if let cell = cell as? EditProfileFieldTableViewCell {
        cell.commitChanges()
      }
      if let cell = cell as? EditAvatarTableViewCell {
        cell.commitChanges()
      }
    }
    CurrentUser.info.model?.updateUser({ (success) -> () in
      if success {
        alertShow(self, alertText: "Success", alertMessage: "Profile Updated Successfully")
        NSNotificationCenter.defaultCenter().postNotificationName("errorFetchingConfig", object: self, userInfo: nil)
        self.reload()
      } else {
        alertShow(self, alertText: "Failure", alertMessage: "Profile Update Unsuccessful")
      }
    })
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
      //upload the image, then put that mediaId as the avatar image
      var image: UIImage?
      if picker.allowsEditing {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        //          self.mediaObject?.thumbnail = self.image
      } else {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //          self.mediaObject?.thumbnail = self.image
      }
      if let image = image {
        self.avatarEditCell?.avatar = image
      }
      //      CurrentUser.info.addAvatarImage(image!, filePath: )
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
