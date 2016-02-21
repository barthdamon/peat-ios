//
//  Networking.swift
//  Peat
//
//  Created by Matthew Barth on 2/21/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

func urlEncoded(urlString: String) -> String {
  if let encoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) {
    return encoded
  } else {
    return urlString
  }
}