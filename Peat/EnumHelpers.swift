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
  case Pre = "pre"
  // toId progressively led to the fromId
  case Post = "post"
  // on the same plane, considered the same difficulty
  case Even = "even"
  // a variation of the from ability
  case Var = "var"
}

enum ChangeStatus {
  case Removed
  case Updated
  case BrandNew
  case Unchanged
}