//
//  ArrayBounds.swift
//  Peat
//
//  Created by Matthew Barth on 2/17/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

extension Array {
  func lookup(index : UInt) throws -> Element {
    if Int(index) >= count {throw
      NSError(domain: "com.sadun", code: 0,
        userInfo: [NSLocalizedFailureReasonErrorKey:
          "Array index out of bounds"])}
    return self[Int(index)]
  }
}

func defaultCell(tableView: UITableView, message: String) -> UITableViewCell {
  if let cell = tableView.dequeueReusableCellWithIdentifier("defaultCell") as? DefaultTableViewCell {
    cell.configureWithMessage(message)
    return cell
  } else {
    return UITableViewCell()
  }
}