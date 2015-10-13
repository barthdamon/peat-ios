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
  
  func postMediaFromFactory(mediaURL :NSURL, mediaID :String, mediaType: MediaType, callback: APICallback) {
    
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
