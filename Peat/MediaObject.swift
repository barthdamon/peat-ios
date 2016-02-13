//
//  MediaObject.swift
//  Peat
//
//  Created by Matthew Barth on 9/28/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

enum MediaPurpose: String {
  case Attempt = "Attempt"
  case Completion = "Completion"
  case Tutorial = "Tutorial"
}

class MediaObject: NSObject {
  
  //parsed
  var _id: String?
  var user_Id: String?
  var mediaId: String?
  var leafId: String?
  var mediaDescription: String?
  var location: String?
  var timestamp: Int?
  var url: NSURL? {
    didSet {
      self.urlString = String(url!)
    }
  }
  var urlString: String?
  var mediaType: MediaType?
  var purpose: MediaPurpose?
  
  //created
  var thumbnail: UIImage?
  var filePath: NSURL?
  var madeLocal: Bool = false
  
  var comments: Array<Comment>?
  var likes: Array<Like>?
  
  var API = APIService.sharedService
  var store: PeatContentStore?
  var needsPublishing: Bool = false
  
  static func initWithJson(json: jsonObject, store: PeatContentStore?) -> MediaObject {
    let media = MediaObject()
    media.store = store
    media._id = json["_id"] as? String
    media.user_Id = json["user_Id"] as? String
    media.mediaId = json["mediaId"] as? String
    media.leafId = json["leafId"] as? String
    media.mediaDescription = json["description"] as? String
    media.location = json["location"] as? String
    media.timestamp = json["timestamp"] as? Int
    if let purpose = json["purpose"] as? String, mediaPurpose = MediaPurpose(rawValue: purpose) {
      media.purpose = mediaPurpose
    }
    
    if let info = json["source"] as? jsonObject, url = info["url"] as? String, mediaType = info["mediaType"] as? String {
      media.url = NSURL(string: url)
      media.mediaType = MediaType(rawValue: mediaType)
    }
    
    if let comments = json["comments"] as? Array<jsonObject> {
      media.comments = Array()
      for comment in comments {
        media.comments!.append(Comment.initFromJson(comment))
      }
    }
    
    if let likes = json["likes"] as? Array<jsonObject> {
      media.likes = Array()
      for like in likes {
        media.likes!.append(Like.initFromJson(like))
      }
    }
    
    return media
  }
  
  func newComment(comment: Comment) {
    if let _ = self.comments {
      self.comments?.append(comment)
    } else {
      self.comments = [comment]
    }
  }
  
  func newLike(like: Like) {
    if let _ = self.likes {
      self.likes?.append(like)
    } else {
      self.likes = [like]
    }
  }
  
  static func initFromUploader(leaf: Leaf?, type: MediaType?, thumbnail: UIImage?, filePath: NSURL?, store: PeatContentStore?) -> MediaObject {
    let media = MediaObject()
    media.needsPublishing = true
    media.store = store
    media.leafId = leaf?.leafId
    media.mediaType = type
    media.thumbnail = thumbnail
    media.filePath = filePath
    media.madeLocal = true
    var typeExtension = ""
    if let type = type {
      typeExtension = type == .Video ? ".mov" : ".img"
    }
    let id = generateId()
    media.mediaId = "\(id)\(typeExtension)"
    return media
  }
  
  func generateThumbnail(media: MediaObject, callback: (UIImage?, NSError?) -> () ) {
    if let url = media.url {
      if let thumbnail = media.thumbnail {
        callback(thumbnail, nil)
      } else {
        if let data = NSData(contentsOfURL: url), image = UIImage(data: data) {
          media.thumbnail = image
          callback(image, nil)
        }
      }
    }
  }
  
  func params() -> jsonObject {
    return [
      "mediaId": paramFor(mediaId),
      "leafId": paramFor(leafId),
      "source": [
        "url" : paramFor(urlString),
        "mediaType" : self.mediaType != nil ? self.mediaType!.rawValue : ""
      ],
      "description": paramFor(mediaDescription),
      "location": paramFor(location)
    ]
  }
  
  func publish() {
    if let mediaType = self.mediaType {
      mediaType == .Image ? bundleImageFile() : sendToAWS()
    }
  }
  
  func bundleImageFile() {
    //write the image data somewhere you can upload from (documents directory)
    if let image = self.thumbnail {
      let fileManager = NSFileManager.defaultManager()
      let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
      let filePathToWrite = "\(paths)/SaveFile.png"
      let imageData: NSData = UIImagePNGRepresentation(image)!
      fileManager.createFileAtPath(filePathToWrite, contents: imageData, attributes: nil)
      
      //get url of where image was just saved
      let urlPaths = NSURL(fileURLWithPath: paths)
      self.filePath = urlPaths.URLByAppendingPathComponent("SaveFile.png")
      sendToAWS()
    }
  }
  
  func sendToAWS() {
    if let type = self.mediaType, filePath = self.filePath {
      if let id = self.mediaId {
        AWSContentHelper.sharedHelper.postMediaFromFactory(filePath, mediaID: id, mediaType: type) { (res, err) in
          if err != nil {
            print(err)
          } else {
            if let mediaId = self.mediaId, url = NSURL(string: "https://s3.amazonaws.com/peat-assets/\(mediaId)") {
              self.url = url
              self.sendToServer()
            }
          }
        }
      }
    }
  }
  
  func sendToServer() {
    API.post(self.params(), authType: HTTPRequestAuthType.Token, url: "media") { (res, err) -> () in
      if let e = err {
        print("Error:\(e)")
      } else {
        print("Server media post successful")
        self.store?.addMediaToStore(self)
        NSNotificationCenter.defaultCenter().postNotificationName("newMediaPostSuccessful", object: self, userInfo: nil)
      }
    }
  }
  
}