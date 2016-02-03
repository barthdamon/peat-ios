//
//  StringHelpers.swift
//  Peat
//
//  Created by Matthew Barth on 1/22/16.
//  Copyright © 2016 Matthew Barth. All rights reserved.
//

import Foundation

func generateId(length:Int = 50)->String{
  let wantedCharacters:NSString="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789"
  let s=NSMutableString(capacity: length)
  for (var i:Int = 0; i < length; i++) {
    let r:UInt32 = arc4random() % UInt32( wantedCharacters.length)
    let c:UniChar = wantedCharacters.characterAtIndex( Int(r) )
    s.appendFormat("%C", c)
  }
  return s as String
}

func paramFor<T>(param: T?) -> String {
  if let param = param {
    return String(param)
  } else {
    return ""
  }
}