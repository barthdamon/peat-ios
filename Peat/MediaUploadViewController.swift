//
//  MediaUploadViewController.swift
//  Peat
//
//  Created by Matthew Barth on 1/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import UIKit
import AVFoundation

protocol MediaUploadDelegate {
  func newMediaAdded()
  func getStore() -> PeatContentStore?
}

class MediaUploadViewController: UIViewController, UIPopoverPresentationControllerDelegate, MediaTagUserDelegate {
  
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var tagOthersButton: UIButton!
  @IBOutlet weak var purposeSelector: UISegmentedControl!
  @IBOutlet weak var mediaView: UIView!
  @IBOutlet weak var descriptionTextField: UITextField!
  
  var editorController: UIVideoEditorController?
  
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
  
  var mediaObject: MediaObject? {
    didSet {
      if let mediaType = mediaType where mediaType == .Video {
        editButton.hidden = false
      }
    }
  }
  
  var player: PeatAVPlayer?
  var videoPath: NSURL?
  var image: UIImage?
  var overlayView: MediaOverlayView?
  
  var uploadFromGallery = false
  
  
  lazy var session: NSURLSession = {
    let config = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    config.allowsCellularAccess = false
    let session = NSURLSession(configuration: NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("VideoDownload"), delegate: self, delegateQueue: NSOperationQueue.currentQueue())
    return session
  }()
  
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
    self.navigationController?.popViewControllerAnimated(true)
  }
  
  func displayGalleryOptions() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let galleryVC = storyboard.instantiateViewControllerWithIdentifier("GalleryCollectionViewController") as! GalleryCollectionViewController
    galleryVC.mode = .Upload
    galleryVC.mediaUploadController = self
    galleryVC.stacked = true
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
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    editorController = UIVideoEditorController()
    editorController?.delegate = self
    setVideoOnEditor()
  }
}

//MARK: Media Upload Methods
extension MediaUploadViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func displayCameraControl() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.allowsEditing = true
    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imagePickerController.videoQuality = .TypeMedium
    imagePickerController.videoMaximumDuration = 60
    
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










extension MediaUploadViewController: UIVideoEditorControllerDelegate, NSURLSessionDelegate {
  
  func videoEditorController(editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
    // put the video up on the tree
    print("EDITED PATH: \(editedVideoPath)")
    self.videoPath = NSURL(fileURLWithPath: editedVideoPath)
    self.mediaType = .Video
    self.editorController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func setVideoOnEditor() {
    if let mediaObject = self.mediaObject {
      if let filePath = mediaObject.filePath?.path {
        populateEditorPath("\(filePath)")
        //done return the filePath, ready to go
      } else if let url = mediaObject.url {
        //download the asset here
        //show loading screen or something
        downloadFromURL(url)
      }
    }
  }
  
  func populateEditorPath(path: String) {
    if UIVideoEditorController.canEditVideoAtPath(path) {
      print("PATH: \(path)")
      if let editor = self.editorController {
        editor.videoPath = path
        self.presentViewController(editor, animated: true, completion: nil)
      }
    } else {
      //show cant edit
    }
  }
  
  func downloadFromURL(url: NSURL) {
    //download the asset, then let the user edit it, then upload it again. hahahahahahaha. create a new asset... with the asset
    let downloadRequest = NSMutableURLRequest(URL: url)
    let downloadTask = session.downloadTaskWithRequest(downloadRequest)
    if let id = mediaObject?._id {
      downloadTask.taskDescription = id
    }
    downloadTask.resume()
  }
  
  
  
  //MARK: Downloading Delegate Methods
  func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
    if let path = location.path {
      populateEditorPath(path)
    }
  }
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    if let e = error {
//      sendDownloadEndNotification("Download Failed: \(e)")
    }
  }
  
  func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
    
    dispatch_async(dispatch_get_main_queue()) {
      print("Download Progress: \(progress)")
//      for subscribed in self.subscribedCells {
//        subscribed.updateWithProgress(progress)
//      }
      //show progress indicator
    }
  }
  
}
