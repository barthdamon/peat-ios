//
//  MediaUploadViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit

protocol MediaUploadDelegate {
  func newMediaAdded()
  func getStore() -> PeatContentStore?
}

class MediaUploadViewController: UIViewController, UIPopoverPresentationControllerDelegate, MediaTagUserDelegate {
  
  @IBOutlet weak var tagOthersButton: UIButton!
  @IBOutlet weak var purposeSelector: UISegmentedControl!
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var descriptionTextField: UITextField!
  
  var userForProfile: User?
  var store: PeatContentStore? {
    return delegate?.getStore()
  }
  
  var leaf: Leaf? {
    return store?.treeStore.selectedLeaf
  }
  
  var selectedPurpose: MediaPurpose = .Attempt
  
  var delegate: MediaUploadDelegate?
  
  var mediaType: MediaType? {
    didSet {
      self.mediaObject = MediaObject.initFromUploader(leaf, type: mediaType, thumbnail: image, filePath: videoPath, store: store)
      if let user = CurrentUser.info.model {
        self.userAdded(user)
      }
      showNewMedia()
    }
  }
  var mediaObject: MediaObject?
  var player: PeatAVPlayer?
  var videoPath: NSURL?
  var image: UIImage?
  var overlayView: MediaOverlayView?
  
  var uploadFromGallery = false

    override func viewDidLoad() {
      super.viewDidLoad()
      self.purposeSelector.addTarget(self, action: "newPurposeSelected:", forControlEvents: .ValueChanged)
      addListeners()
      if uploadFromGallery {
        displayGalleryOptions()
      } else {
        displayCameraControl()
      }
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
  
  func mediaFromGallery(media: MediaObject) {
    self.mediaObject = media
    if let leaf = self.leaf {
      media.setMediaToLeaf(leaf)
    }
    showNewMedia()
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
  

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
      if segue.identifier == "tagUserSegue" {
        if let vc = segue.destinationViewController as? TagUserTableViewController {
          vc.mediaTagDelegate = self
          vc.user = CurrentUser.info.model
          vc.media = self.mediaObject
          let popover = vc.popoverPresentationController
          popover?.delegate = self
          vc.popoverPresentationController?.delegate = self
          //        vc.popoverPresentationController?.sourceView = self.view
          //        vc.popoverPresentationController?.sourceRect = CGRectMake(100,100,0,0)
          vc.preferredContentSize = CGSize(width: self.view.frame.width, height: 200)
        }
      }
      
      if segue.identifier == "profileFromUploader" {
        if let vc = segue.destinationViewController as? ProfileViewController {
          vc.viewing = self.userForProfile
        }
      }
    }
  
  func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
    return .None
  }
  
  func userAdded(user: User) {
    self.mediaObject?.tagUserOnMedia(user)
    var count = 0
    if let tagged = self.mediaObject?.taggedUsers {
      count += tagged.count
    }
    self.tagOthersButton.setTitle("\(count) Tagged", forState: .Normal)
    //do something to show the user has been tagged
    //perhaps a list of the users tagged or something?
  }

  func dismissSelf(animated: Bool) {
    self.navigationController?.popToRootViewControllerAnimated(animated)
  }
  
  func displayGalleryOptions() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let galleryVC = storyboard.instantiateViewControllerWithIdentifier("GalleryCollectionViewController") as! GalleryCollectionViewController
    galleryVC.mode = .Upload
    galleryVC.mediaUploadController = self
    self.navigationController?.pushViewController(galleryVC, animated: true)
//    self.performSegueWithIdentifier("showGallery", sender: self)
  }

  @IBAction func publishButtonPressed(sender: AnyObject) {
    if let _ = self.mediaObject {
      self.mediaObject?.mediaDescription = self.descriptionTextField.text
      self.mediaObject?.purpose = self.selectedPurpose
      store?.addMediaToStore(self.mediaObject!, publishImmediately: false)
      self.delegate?.newMediaAdded()
      dismissSelf(true)
    }
//    self.mediaObject?.publish()
  }
  
  @IBAction func tagOthersButtonPressed(sender: AnyObject) {
    //tag the other
    self.performSegueWithIdentifier("tagUserSegue", sender: self)
  }
  
  func userIsTagged(user: User) -> Bool {
    if let tagged = self.mediaObject?.taggedUsers {
      for taggedUser in tagged {
        if taggedUser._id == user._id {
          return true
        }
      }
    }
    return false
  }
  
  func showUserProfile(user: User) {
    self.userForProfile = user
    self.performSegueWithIdentifier("profileFromUploader", sender: self)
  }
  
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    dismissSelf(false)
  }
  
  func newPurposeSelected(sender: UISegmentedControl) {
    let index = sender.selectedSegmentIndex
    self.selectedPurpose = index == 0 ? .Attempt : .Tutorial
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
}
