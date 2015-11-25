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
  var selectedLeaf: LeafNode?
  var video: NSURL?
  var image: UIImage?
  var leaves: Array<LeafNode>?
  
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
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func featchLeaves() {
    if !initializeLeaves() {
      //show loading view or something
    }
  }
  
  func initializeLeaves() -> Bool {
    //right now it redraws every time... no harm in that
    if let leaves = PeatContentStore.sharedStore.getLeaves(.Trampoline) {
      self.leaves = leaves
      populatePickerView()
      return true
    } else {
      return false
    }
  }
  
  func populatePickerView() {
    
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
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 1
  }
  
//  func configureThumbnailOverlay() {
//    let asset = AVURLAsset(URL: self.videoPath!)
//    let imageGenerator = AVAssetImageGenerator(asset: asset)
//    imageGenerator.appliesPreferredTrackTransform=true
//    //    let durationSeconds = CMTimeGetSeconds(asset.duration)
//    let midPoint = CMTimeMakeWithSeconds(1, 1)
//    imageGenerator.generateCGImagesAsynchronouslyForTimes( [ NSValue(CMTime:midPoint) ], completionHandler: {
//      (requestTime, thumbnail, actualTime, result, error) -> Void in
//      
//      if let thumbnail = thumbnail {
//        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//          self.videoOverlayView = UIView(frame: self.mediaView.bounds)
//          
//          if let overlay = self.videoOverlayView {
//            let thumbnailView = UIImageView(frame: self.mediaView.bounds)
//            thumbnailView.contentMode = .ScaleAspectFit
//            thumbnailView.image = UIImage(CGImage: thumbnail)
//            
//            overlay.addSubview(thumbnailView)
//            
//            let playButtonContainerSize: CGFloat = 70
//            
//            let playButtonContainer = UIView(frame: CGRectMake(0, 0, playButtonContainerSize, playButtonContainerSize))
//            playButtonContainer.layer.cornerRadius = playButtonContainerSize/2;
//            playButtonContainer.layer.masksToBounds = true
//            playButtonContainer.backgroundColor = UIColor.whiteColor()
//            playButtonContainer.alpha = 0.3
//            playButtonContainer.center = overlay.center
//            
//            let playButton = UIImageView(image: self.playButtonIcon)
//            playButton.center = playButtonContainer.center
//            playButton.alpha = 0.6
//            
//            overlay.addSubview(playButtonContainer)
//            overlay.addSubview(playButton)
//            
//            let tap = UITapGestureRecognizer(target: self, action: "togglePlaystate")
//            tap.numberOfTapsRequired = 1
//            tap.numberOfTouchesRequired = 1
//            overlay.addGestureRecognizer(tap)
//            
//            self.mediaView.addSubview(overlay)
//          }
//        })
//      }
//    })
//  }


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
