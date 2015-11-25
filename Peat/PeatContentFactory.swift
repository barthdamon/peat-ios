//
//  PeatContentFactory.swift
//  Peat
//
//  Created by Matthew Barth on 10/5/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import UIKit

struct LocalMedia {
  var mediaId: String?
  var mediaType: MediaType?
  var filePath: NSURL?
  var image: UIImage?
  var leafPath: String?
  var leaf: LeafNode?
  var description: String?
}

private let _mainFactory = PeatContentFactory()


class PeatContentFactory: NSObject {
  
  class var mainFactory: PeatContentFactory {
    return _mainFactory
  }
  
  func publishMedia(media: LocalMedia) {
    if let mediaType = media.mediaType {
      switch mediaType {
      case .Image:
        bundleImageFile(media)
      case .Video:
        bundleVideoFile(media)
      case .Other:
        break
      }
    }
  }
  
  func bundleVideoFile(media :LocalMedia) {
    if let filePath = media.filePath {
      let pathString = filePath.relativePath
      //Might have to do this for stored images too if user takes with a camera
      UISaveVideoAtPathToSavedPhotosAlbum(pathString!, self, nil, nil)
      postMedia(media)
    }
  }
  
  
  func bundleImageFile(var media: LocalMedia) {
    //write the image data somewhere you can upload from (documents directory)
    if let image = media.image {
      let fileManager = NSFileManager.defaultManager()
      let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
      let filePathToWrite = "\(paths)/SaveFile.png"
      let imageData: NSData = UIImagePNGRepresentation(image)!
      fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
      
      //get url of where image was just saved
      let urlPaths = NSURL(fileURLWithPath: paths)
      media.filePath = urlPaths.URLByAppendingPathComponent("SaveFile.png")
      postMedia(media)
    }
  }
  
  func postMedia(var media: LocalMedia) {
    if let type = media.mediaType, filePath = media.filePath {
      let typeExtension = type == .Video ? ".mov" : ".img"
      let id = generateID(30)
      media.mediaId = "\(id)\(typeExtension)"
      if let id = media.mediaId {
        AWSContentHelper.sharedHelper.postMediaFromFactory(filePath, mediaID: id, mediaType: type) { (res, err) in
          if err != nil {
            print(err)
          } else {
            self.sendToServer(media)
          }
        }
      }
    }
  }

  func sendToServer(media: LocalMedia) {
    if let id = media.mediaId, description = media.description, leafPath = media.leafPath, leafId = media.leaf?.id, type = media.mediaType {
      let url = "https://s3.amazonaws.com/peat-assets/\(id)"
      APIService.sharedService.post(["params":["mediaInfo": ["mediaID": id, "url" : url, "mediaType": type.rawValue], "leaf": leafId, "meta": ["leafPath": leafPath, "description": description]]], authType: HTTPRequestAuthType.Token, url: "media")
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