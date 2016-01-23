//
//  MediaUploadViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class MediaUploadViewController: UIViewController {
  
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var descriptionTextField: UITextField!
  @IBOutlet weak var locationTextField: UITextField!
  
  var leaf: Leaf?
  var overlayView: MediaOverlayView?
  
  var mediaType: MediaType? {
    didSet {
      self.mediaObject = MediaObject.initFromUploader(leaf, type: mediaType, thumbnail: image, filePath: videoPath)
      self.overlayView = MediaOverlayView(mediaView: mediaView, player: nil, mediaObject: self.mediaObject, delegate: nil)
    }
  }
  var mediaObject: MediaObject?
  var videoPath: NSURL?
  var image: UIImage?

    override func viewDidLoad() {
      super.viewDidLoad()
      
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

  @IBAction func publishButtonPressed(sender: AnyObject) {
    self.mediaObject?.publish()
  }
  
  @IBAction func cancelButtonPressed(sender: AnyObject) {
  }
  
}

//MARK: Media Upload Methods
extension MediaUploadViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func displayCameraControl() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    
    //Allows for video and images:
    if let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePickerController.sourceType) {
      imagePickerController.mediaTypes = availableMediaTypes
    }
    
    self.presentViewController(imagePickerController, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    // dismiss the image picker controller window
    self.dismissViewControllerAnimated(true, completion: nil)
    
    //Determine if Video or Image Data
    if (info[UIImagePickerControllerEditedImage] == nil && info[UIImagePickerControllerOriginalImage] == nil) {
      //VIDEO
      videoPath = info[UIImagePickerControllerMediaURL] as? NSURL
      mediaType = .Video
    } else {
      //IMAGE
      // fetch the selected image
      if picker.allowsEditing {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
      } else {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
      }
      mediaType = .Image
    }
  }
}
