//
//  Helpers.swift
//  Super Koalio
//
//  Created by JackieDog on 6/22/17.
//  Copyright © 2017 JackieDog. All rights reserved.
//

import Foundation

public func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
  return min(max(value, lower), upper)
}
