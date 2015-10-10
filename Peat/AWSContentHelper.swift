//
//  AWSContentHelper.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit
import AWSCore
import AWSS3


//MARK: Content Store
private let _sharedHelper = AWSContentHelper()

class AWSContentHelper: NSObject {
  
  var API = APIService.sharedService
  
  var photoObjects: Array<PhotoObject> = []
  
  class var sharedHelper: AWSContentHelper {
    return _sharedHelper
  }
  
  func generateThumbnails(mediaObjects :Array<PhotoObject>,  callback: (Array<PhotoObject>?) -> () ) {
//    var imageFromMedia: UIImage?
    var count = 0
    
    func makeRequest() {
      let currentObject = mediaObjects[count]
      let mediaID = currentObject.mediaID!
      
      let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
      let filePath = "\(paths)/\(mediaID).png"
      let filePathToWrite = NSURL(fileURLWithPath: filePath)
      
      let downloadRequest = AWSS3TransferManagerDownloadRequest()
      downloadRequest.bucket = "peat-assets"
      downloadRequest.key  = "\(mediaID)" //fileName on s3
      downloadRequest.downloadingFileURL = filePathToWrite
      
      let transferManager = AWSS3TransferManager.defaultS3TransferManager()
      transferManager.download(downloadRequest).continueWithBlock {
        (task: AWSTask!) -> AnyObject! in
        if task.error != nil {
          print("Error downloading")
          return nil
        }
        else {
          print(filePathToWrite)
          if let imageData = NSData(contentsOfURL: filePathToWrite), image = UIImage(data: imageData) {
            currentObject.thumbnail = image
            ++count
            if count < mediaObjects.count {
              makeRequest()   
            } else {
              callback(mediaObjects)
            }
            return nil
          } else {
            callback(nil)
            return nil
          }
        }
      }
    } // END MAKEREQUEST()
    
      makeRequest()
  }
  
  func downloadVideos(mediaObjects :Array<VideoObject>,  callback: (Array<VideoObject>?) -> () ) {
    var count = 0
    
    func makeRequest() {
      let currentObject = mediaObjects[count]
      let mediaID = currentObject.mediaID!
      
      let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
      let filePath = "\(paths)/\(mediaID).mov"
      let filePathToWrite = NSURL(fileURLWithPath: filePath)
      
      let downloadRequest = AWSS3TransferManagerDownloadRequest()
      downloadRequest.bucket = "peat-assets"
      downloadRequest.key  = "\(mediaID)" //fileName on s3
      downloadRequest.downloadingFileURL = filePathToWrite
      
      let transferManager = AWSS3TransferManager.defaultS3TransferManager()
      transferManager.download(downloadRequest).continueWithBlock {
        (task: AWSTask!) -> AnyObject! in
        if task.error != nil {
          print("Error downloading")
          return nil
        }
        else {
          print(filePathToWrite)
          currentObject.videoFilePath = filePathToWrite
          callback(mediaObjects)
          return nil
//          if let imageData = NSData(contentsOfURL: filePathToWrite) {
//            currentObject.thumbnail = image
//            ++count
//            if count < mediaObjects.count {
//              makeRequest()
//            } else {
//              callback(mediaObjects)
//            }
//            return nil
//          } else {
//            callback(nil)
//            return nil
//          }
        }
      }
    } // END MAKEREQUEST()
    
    makeRequest()
  }
  
  
  func postMediaFromFactory(mediaURL :NSURL, mediaID :String, mediaType: MediaType, callback: APICallback) {
    //make a timestamp variable to use in the key of the video I'm about to upload
    let date:NSDate = NSDate()
    let unixTimeStamp:NSTimeInterval = date.timeIntervalSince1970
    let unixTimeStampString:String = String(format:"%f", unixTimeStamp)
    print("this is my unix timestamp as a string: \(unixTimeStampString)")
    
    //upload to aws
    let uploadRequest: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest.bucket = "peat-assets"
    uploadRequest.key = "\(mediaID)"
    uploadRequest.contentType = mediaType == .Video ? "video/quicktime" : mediaType.toString()
    uploadRequest.body = mediaURL
    
    //    make a timestamp variable to use in the key of the video I'm about to upload
    let transferManager:AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
    transferManager.upload(uploadRequest).continueWithBlock { (task :AWSTask!) -> AnyObject! in
      print("I'm inside the completion block")
      if ((task.result) != nil) {
        print("upload was successful?")
        callback(nil,nil)
      } else {
        print("upload didn't seem to go through..")
        let myError = task.error
        print("error: \(myError)")
        callback(nil, myError)
      }
      return nil
    }
  }
  
}
