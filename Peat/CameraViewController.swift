//
//  CameraViewController.swift
//  Peat
//
//  Created by Matthew Barth on 9/23/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import UIKit
import Foundation
import AWSCore
import AWSS3
import AWSDynamoDB
import AWSCognito

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
    
    
    let fileManager = NSFileManager.defaultManager()
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let filePathToWrite = "\(paths)/SaveFile.png"
    let imageData: NSData = UIImagePNGRepresentation(image!)!
    fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
    
    let urlPaths = NSURL(fileURLWithPath: paths)
    let getImagePath = urlPaths.URLByAppendingPathComponent("SaveFile.png")
    let mediaID = generateID(30)
    print(mediaID)
    
    //make a timestamp variable to use in the key of the video I'm about to upload
    let date:NSDate = NSDate()
    let unixTimeStamp:NSTimeInterval = date.timeIntervalSince1970
    let unixTimeStampString:String = String(format:"%f", unixTimeStamp)
    print("this is my unix timestamp as a string: \(unixTimeStampString)")
    
    let uploadRequest: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest.bucket = "peat-assets"
    uploadRequest.key = "\(mediaID)"
    uploadRequest.contentType = "image"
    uploadRequest.body = getImagePath
    
    
    //    make a timestamp variable to use in the key of the video I'm about to upload
    let transferManager:AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
    transferManager.upload(uploadRequest).continueWithBlock { (task :AWSTask!) -> AnyObject! in
          print("I'm inside the completion block")
          if((task.result) != nil){
            print("upload was successful?")
            self.sendToServer(mediaID, mediaType: .Photo)
          }else{
            print("upload didn't seem to go through..")
            let myError = task.error
            print("error: \(myError)")
          }
          return nil
        }
  }
  
  func sendToServer(mediaID: String, mediaType: MediaType){
    APIService.sharedService.post(["params":["mediaInfo": ["mediaID": mediaID, "mediaType": mediaType.toString()]]], authType: HTTPRequestAuthType.Token, url: "media")
        { (res, err) -> () in
            if let e = err {
              print("Error:\(e)")
            } else {
              if let json = res as? Dictionary<String, AnyObject> {
                print(json)
              }
        }
    }
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
  
  func generateID(length:Int)->String{
    let wantedCharacters:NSString="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789"
    let s=NSMutableString(capacity: length)
    for (var i:Int = 0; i < length; i++) {
      let r:UInt32 = arc4random() % UInt32( wantedCharacters.length)
      let c:UniChar = wantedCharacters.characterAtIndex( Int(r) )
      s.appendFormat("%C", c)
    }
    return s as String
  }
}
