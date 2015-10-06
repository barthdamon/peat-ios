//
//  VideoObject.swift
//  Peat
//
//  Created by Matthew Barth on 10/5/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation

class VideoObject: MediaObject {
  
  var videoFile: NSData?
  
  func videoWithJson(json: jsonObject) -> VideoObject {
    let newVideo = VideoObject()
    newVideo.initWithJson(json)
    newVideo.videoFile = nil
    return newVideo
  }
  
}