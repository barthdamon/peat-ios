//
//  NotificationHelper.swift
//  Peat
//
//  Created by Matthew Barth on 3/6/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation


private var _sharedHelper = NotificationHelper()

class NotificationHelper: NSObject {
  
  class var sharedHelper: NotificationHelper {
    return _sharedHelper
  }
  
  var API = APIService.sharedService
  lazy var store = PeatContentStore()
  
  var currentNotifications: Array<Notification>?
  
  
  func getNotifications(callback: (Array<Notification>) -> ()) {
    API.get(nil, authType: .Token, url: "mail/notifications") { (res, err) -> () in
      if let e = err {
        print("Error getting notifications: \(e)")
        callback([])
      } else {
        if let json = res as? jsonObject, notifications = json["notifications"] as? Array<jsonObject> {
          var newNotifications: Array<Notification> = []
          notifications.forEach({ (notificationJson) -> () in
            newNotifications.append(Notification.notificationFromJson(notificationJson))
          })
          self.currentNotifications = newNotifications
          callback(newNotifications)
        }
      }
    }
  }
  
  func markCurrentNotificationsAsSeen() {
    var notificationParams: Array<String> = []
    currentNotifications?.forEach({ (notification) -> () in
      notificationParams.append(notification.params())
    })
    API.put(["notificationIds" : notificationParams], authType: .Token, url: "mail/notifications") { (res, err) -> () in
      if let e = err {
        print("Notification seen error: \(e)")
      } else {
        print("Notification seen update successful")
        NSNotificationCenter.defaultCenter().postNotificationName("notificationsSeen", object: nil, userInfo: nil)
      }
    }
  }
  
}


enum NotificationType: String {
  case Comment = "comment"
  case Like = "like"
  case Tag = "tag"
  case Repost = "repost"
  case Follow = "follow"
  case Witness = "witness"
}


class Notification: NSObject {
  //notification stuff
  var _id: String?
  
  var userNotifying_Id: String?
  var userNotifying: User?
  
  var mediaId: String?
  var mediaObject: MediaObject?
  
  var leafId: String?
  var leaf: Leaf?
  
  var datePosted: FormattedDate?
  var timestamp: Double? {
    didSet {
      if let timestamp = timestamp {
        datePosted = FormattedDate.dateFromTimestamp(timestamp)
      }
    }
  }
  var seen: Bool?
  var type: NotificationType?
  
  
  static func notificationFromJson(json: jsonObject) -> Notification {
    let newNotification = Notification()
    newNotification.userNotifying_Id = json["userToNotify_Id"] as? String
    if let userNotifyingJson = json["userNotifying"] as? jsonObject {
      newNotification.userNotifying = User.userFromProfile(["userInfo": userNotifyingJson])
    }
    newNotification.mediaId = json["mediaId"] as? String
    if let mediaObjectJson = json["mediaObject"] as? jsonObject {
      newNotification.mediaObject = MediaObject.initWithJson(mediaObjectJson, store: NotificationHelper.sharedHelper.store)
    }
    
    newNotification.leafId = json["leafId"] as? String
    if let leafJson = json["leafInfo"] as? jsonObject {
      newNotification.leaf = Leaf.initWithJson(leafJson, delegate: nil)
      //dang leaf needs a delegate....
    }
    
    newNotification.timestamp = json["timestamp"] as? Double
    newNotification.seen = json["seen"] as? Bool
    if let typeString = json["type"] as? String {
      newNotification.type = NotificationType(rawValue: typeString)
    }
    return newNotification
  }
  
  func params() -> String {
    return paramFor(_id)
  }
  
}
