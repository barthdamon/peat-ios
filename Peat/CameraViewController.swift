//
//  CameraViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/23/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import Foundation

enum SelectedMedia {
  case Image
  case Video
}

class CameraViewController: UIViewController, ViewControllerWithMenu, UIPickerViewDelegate, UIPickerViewDataSource {
  
  var sidebarClient: SideMenuClient?
  var selectedMedia: SelectedMedia?
  var selectedLeaf: Leaf?
  var video: NSURL?
  var image: UIImage?
  var leaves: Array<Leaf>?
  
  @IBOutlet weak var imagePickerView: UIPickerView!
  @IBOutlet weak var leafPathLabel: UILabel!
  @IBOutlet weak var titleLabel: UITextField!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var publishButton: UIButton!
  @IBOutlet weak var saveButton: UIButton!

  override func viewDidLoad() {
      super.viewDidLoad()
    cameraBtnTapped()
    initializeSidebar()
    configureNavBar()
    configureMenuSwipes()
    
    fetchLeaves()
      // Do any additional setup after loading the view.
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "initializeLeaves", name: "leavesPopulated", object: nil)
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func fetchLeaves() {
    if !initializeLeaves() {
      //show loading view or something
    }
  }
  
  func initializeLeaves() -> Bool {
    //right now it redraws every time... no harm in that
//    if let leaves = PeatContentStore.sharedStore.getLeaves(.Trampoline) {
//      self.leaves = leaves
//      self.imagePickerView.reloadAllComponents()
//      return true
//    } else {
//      return false
//    }
    return false
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
  
  //MARK Media Formatting
  
  func cameraBtnTapped() {
    displayCameraControl()
  }

  func postMedia() {
    if let media = self.selectedMedia {
      var localMedia = LocalMedia()
      switch media {
      case .Video:
        if let video = self.video {
          localMedia = LocalMedia(mediaId: nil, mediaType: .Video, filePath: video, image: nil, leafPath: leafPathLabel.text, leaf: selectedLeaf, description: titleLabel.text)
        }
      case .Image:
        if let image = self.image {
          localMedia = LocalMedia(mediaId: nil, mediaType: .Image, filePath: nil, image: image, leafPath: leafPathLabel.text, leaf: selectedLeaf, description: titleLabel.text)
        }
      }
      PeatContentFactory.mainFactory.publishMedia(localMedia)
    }
  }
  
  func generateThumbnail() {
    if let image = self.image {
      self.imageView.image = image
    }
  }
  
  //MARK: Picker view delegate methods
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  //number of views in the picker
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.leaves != nil ? self.leaves!.count : 1
  }
  
  //returns the title for each row
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if let leaves = self.leaves {
      let leaf = leaves[row]
      return leaf.title
    } else {
      return nil
    }
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if let leaves = self.leaves {
      self.selectedLeaf = leaves[row]
      if let leafSelected = self.selectedLeaf {
        self.leafPathLabel.text = leafSelected.title
      }
    }
  }


  @IBAction func publishButtonPressed(sender: AnyObject) {
    postMedia()
  }
  
  @IBAction func saveButtonPressed(sender: AnyObject) {
  }
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
      video = info[UIImagePickerControllerMediaURL] as? NSURL
      selectedMedia = .Video
      generateThumbnail()
    } else {
      //IMAGE
      // fetch the selected image
      if picker.allowsEditing {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
      } else {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
      }
      selectedMedia = .Image
      generateThumbnail()
    }
  }
  
}
