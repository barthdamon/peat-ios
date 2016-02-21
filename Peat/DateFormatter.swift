//
//  DateFormatter.swift
//  Peat
//
//  Created by Matthew Barth on 2/21/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

struct FormattedDate {
  var shortString: String!
  var longString: String!
  var date: NSDate!
  
  static func dateFromTimestamp(timestamp: Double) -> FormattedDate {
    var newDate = FormattedDate()
    newDate.date = NSDate(timeIntervalSince1970: timestamp)
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.ShortStyle
    formatter.timeStyle = .ShortStyle
    newDate.shortString = formatter.stringFromDate(newDate.date)
    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
    newDate.longString = formatter.stringFromDate(newDate.date)
    return newDate
  }
}
