//
//  EnumHelpers.swift
//  Peat
//
//  Created by Matthew Barth on 1/18/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

enum CompletionStatus: String {
  case Completed = "Completed"
  case Learning = "Learning"
  case Goal = "Goal"
}

enum LeafConnectionType: String {
  case pre = "pre"
  case post = "post"
  case even = "even"
}