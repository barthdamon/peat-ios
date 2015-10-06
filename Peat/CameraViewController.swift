//
//  CameraViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/23/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import Foundation

class CameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
      cameraBtnTapped()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    func cameraBtnTapped() {
      displayCameraControl()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

  @IBOutlet weak var imageView: UIImageView!
}

// MARK: Camera Extension

extension CameraViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func displayCameraControl() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
      
      if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) {
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Front
      } else {
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDevice.Rear
      }
    } else {
      imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    }
    
    self.presentViewController(imagePickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    // dismiss the image picker controller window
    self.dismissViewControllerAnimated(true, completion: nil)
    
    var image: UIImage?
    // fetch the selected image
    if picker.allowsEditing {
      image = info[UIImagePickerControllerEditedImage] as? UIImage
    } else {
      image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    self.imageView.image = image
    PeatContentFactory.mainFactory.bundleImageFile(image!)
  }


  //FOR VIDEO:
//  let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
//  let videoData = NSData(contentsOfURL: videoURL)
//  let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//  let documentsDirectory: AnyObject = paths[0]
//  let dataPath = documentsDirectory.stringByAppendingPathComponent("/vid1.mp4")
//  
//  videoData?.writeToFile(dataPath, atomically: false)
//  self.dismissViewControllerAnimated(true, completion: nil)
//
//
  
}
