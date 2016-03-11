//
//  EnumHelpers.swift
//  Peat
//
//  Created by Matthew Barth on 1/18/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

enum CompletionStatus: String {
  case Uploaded = "Uploaded"
  case Goal = "Goal"
}

enum LeafConnectionType: String {
  
  // fromId progressively led to the toId
  // signified by a forwards pointing arrow
  case Pre = "pre"
  
  // toId progressively led to the fromId
  // signified by a backwards arrow
  case Post = "post"
  
  // on the same plane, considered the same difficulty or a variation
  // signified by no marking on the middle of the connection
  case Even = "even"
}

enum ChangeStatus {
  case Removed
  case Updated
  case BrandNew
  case Unchanged
}