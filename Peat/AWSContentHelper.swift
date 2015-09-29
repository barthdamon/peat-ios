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
  var mediaObjects = Array<MediaObject>?()
  
  class var sharedHelper: AWSContentHelper {
    return _sharedHelper
  }
  
    func downloadPhoto(mediaID :String, callback :APICallback) {
  
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
          print(task.error.description)
          return "HI"
        }
        else {
          print(filePathToWrite)
          //        var err: NSError?
          if let imageData = NSData(contentsOfURL: filePathToWrite) {
            let currentImage = UIImage(data: imageData)
            //append to an array and return it
          }
          return "HI"
        }
      }
      
    }
  
  
}
