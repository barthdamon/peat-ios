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
  
  var leaf: Leaf? {
    return PeatContentStore.sharedStore.treeStore.selectedLeaf
  }
  
  var overlayView: MediaOverlayView?
  
  var leafDetailDelegate: LeafDetailViewController?
  
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
      displayCameraControl()
      addListeners()
      // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func addListeners() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaPostSuccess", name: "newMediaPostSuccessful", object: nil)
    let tapRecognizer = UITapGestureRecognizer(target: self, action: "resignResponder")
    tapRecognizer.numberOfTapsRequired = 1
    tapRecognizer.numberOfTouchesRequired = 1
    self.view.addGestureRecognizer(tapRecognizer)
  }
  
  func resignResponder() {
    self.descriptionTextField.resignFirstResponder()
    self.locationTextField.resignFirstResponder()
  }
  
  func mediaPostSuccess() {
//    self.leafDetailDelegate?.tableView.reloadData() = true
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
      self.dismissSelf(true)
    })
  }
  

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  func dismissSelf(animated: Bool) {
    self.navigationController?.popToRootViewControllerAnimated(animated)
  }

  @IBAction func publishButtonPressed(sender: AnyObject) {
    self.mediaObject?.mediaDescription = self.descriptionTextField.text
    self.mediaObject?.location = self.locationTextField.text
    self.mediaObject?.publish()
  }
  
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    dismissSelf(false)
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
    
    self.navigationController?.presentViewController(imagePickerController, animated: false, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    // dismiss the image picker controller window
    self.dismissViewControllerAnimated(true, completion: {
      //Determine if Video or Image Data
      if (info[UIImagePickerControllerEditedImage] == nil && info[UIImagePickerControllerOriginalImage] == nil) {
        //VIDEO
        self.videoPath = info[UIImagePickerControllerMediaURL] as? NSURL
        self.mediaType = .Video
      } else {
        //IMAGE
        // fetch the selected image
        if picker.allowsEditing {
          self.image = info[UIImagePickerControllerEditedImage] as? UIImage
        } else {
          self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        self.mediaType = .Image
      }
    })
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(false, completion: {
      self.dismissSelf(false)
    })
  }
}
