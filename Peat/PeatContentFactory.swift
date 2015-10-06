//
//  PeatContentFactory.swift
//  Peat
//
//  Created by Matthew Barth on 10/5/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

private let _mainFactory = PeatContentFactory()


class PeatContentFactory: NSObject {
  
  class var mainFactory: PeatContentFactory {
    return _mainFactory
  }
  
  
  func bundleImageFile(image :UIImage) {
    
    //write the image data somewhere you can upload from (documents directory)
    let fileManager = NSFileManager.defaultManager()
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    let filePathToWrite = "\(paths)/SaveFile.png"
    let imageData: NSData = UIImagePNGRepresentation(image)!
    fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
    
    
    //get url of where image recently saved
    let urlPaths = NSURL(fileURLWithPath: paths)
    let getImagePath = urlPaths.URLByAppendingPathComponent("SaveFile.png")
    let mediaID = generateID(30)
    AWSContentHelper.sharedHelper.postMediaFromFactory(getImagePath, mediaID: mediaID) { (res, err) in
      if err != nil {
        print(err)
      } else {
        self.sendToServer(mediaID, mediaType: .Photo)
      }
    }
  }

  func sendToServer(mediaID: String, mediaType: MediaType) {
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