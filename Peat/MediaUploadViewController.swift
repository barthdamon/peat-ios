//
//  MediaUploadViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

class MediaUploadViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
  @IBOutlet weak var pickerView: UIPickerView!
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var descriptionTextField: UITextField!
  var store: PeatContentStore? {
    return leafDetailDelegate?.profileDelegate?.store
  }
  
  var leaf: Leaf? {
    return store?.treeStore.selectedLeaf
  }
  
  var overlayView: MediaOverlayView?
  var pickerOptions: Array<MediaPurpose> = [MediaPurpose.Completion,MediaPurpose.Attempt,MediaPurpose.Tutorial]
  var selectedPurpose: MediaPurpose?
  
  var leafDetailDelegate: LeafDetailViewController?
  
  var mediaType: MediaType? {
    didSet {
      self.mediaObject = MediaObject.initFromUploader(leaf, type: mediaType, thumbnail: image, filePath: videoPath, store: store)
      showNewMedia()
    }
  }
  var mediaObject: MediaObject?
  var player: PeatAVPlayer?
  var videoPath: NSURL?
  var image: UIImage?

    override func viewDidLoad() {
      super.viewDidLoad()
      displayCameraControl()
      addListeners()
    
      // Do any additional setup after loading the view.
    }
  
  override func viewWillDisappear(animated: Bool) {
    self.player?.stopPlaying()
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func addListeners() {
    let tapRecognizer = UITapGestureRecognizer(target: self, action: "resignResponder")
    tapRecognizer.numberOfTapsRequired = 1
    tapRecognizer.numberOfTouchesRequired = 1
    self.view.addGestureRecognizer(tapRecognizer)
  }
  
  func resignResponder() {
    self.descriptionTextField.resignFirstResponder()
  }
  
  func showNewMedia() {
    if let type = self.mediaObject?.mediaType {
      switch type {
      case .Image:
        configureForImage()
      case .Video:
        configureForVideo()
      default:
        break
      }
    }
  }
  
  func configureForImage() {
    if let mediaView = self.mediaView {
      self.overlayView = MediaOverlayView(mediaView: mediaView, player: nil, mediaObject: self.mediaObject, delegate: self)
    }
  }
  
  func configureForVideo() {
    if let media = self.mediaObject, mediaView = self.mediaView {
      self.player = PeatAVPlayer(playerView: mediaView, media: media)
      self.overlayView = MediaOverlayView(mediaView: mediaView, player: self.player, mediaObject: self.mediaObject, delegate: self)
      self.mediaView.userInteractionEnabled = true
      self.overlayView?.userInteractionEnabled = true
    }
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
    if let _ = self.mediaObject {
      self.mediaObject?.mediaDescription = self.descriptionTextField.text
      self.mediaObject?.purpose = self.selectedPurpose
      store?.addMediaToStore(self.mediaObject!)
      self.leafDetailDelegate?.newMediaAdded()
      dismissSelf(true)
    }
//    self.mediaObject?.publish()
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
        self.mediaObject?.filePath = self.videoPath
        
      } else {
        //IMAGE
        // fetch the selected image
        if picker.allowsEditing {
          self.image = info[UIImagePickerControllerEditedImage] as? UIImage
          self.mediaObject?.thumbnail = self.image
        } else {
          self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
          self.mediaObject?.thumbnail = self.image
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
  
  
  
  //MARK: UIPickerView
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.selectedPurpose = pickerOptions[row]
  }
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 3
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
    return pickerOptions[row].rawValue
  }
}
