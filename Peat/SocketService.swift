//
//  SocketService.swift
//  Peat
//
//  Created by Matthew Barth on 11/19/15.
//  Copyright © 2015 Matthew Barth. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift


private let _sharedService = SocketService()


class SocketService: NSObject {
  
  class var sharedService: SocketService {
    return _sharedService
  }
  
  var socket: SocketIOClient?
  
  func configureSocket() {
    socket = SocketIOClient(socketURL: "localhost:8080", options : ["authToken":  "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI1NjIyOWZhOTI4NmMyMDZkNzRmZWFiYzciLCJleHAiOjE0NDU5OTgyMzk5ODl9.Riw9k0ffHu6gx1nMcdC8opviKPuIX7y1Xjv-3t-VBaA"])
//    socket.on("important message") {data, ack in
//      print("Message for you! \(data[0])")
//      ack("I got your message, and I'll send my response")
//      socket.emit("response", "Hello!")
//    }
    socket?.connect()
    setupHandlers()
  }
  
  func setupHandlers() {
    if let socket = self.socket {
      socket.on("connect") { (data, ack) in
        print("SOCKET CONNECT EVENT RECIEVED: \(data)")
        self.emitMessageSent()
      }
    }
  }
  
  func emitMessageSent() {
    print("Attempting")
    socket?.emit("message", ["message" : "Friend Request I Guess"])
  }
  
}