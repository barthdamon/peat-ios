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
  case Pre = "pre"
  case Post = "post"
  case Even = "even"
}

enum ChangeStatus {
  case Removed
  case Updated
  case BrandNew
  case Unchanged
}