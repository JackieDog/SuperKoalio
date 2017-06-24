//
//  Types.swift
//  Super Koalio
//
//  Created by JackieDog on 6/21/17.
//  Copyright © 2017 JackieDog. All rights reserved.
//

import Foundation

typealias TileCoordinates = (column: Int, row: Int)

enum TilePositions: Int {
  case TopLeft = 0
  case Top = 1
  case TopRight = 2
  case Left = 3
  case Middle = 4
  case Right = 5
  case BottomLeft = 6
  case Bottom = 7
  case BottomRight = 8
}

// The positions of the tiles that surround the player.
let TileIndices: [TilePositions] = [.Bottom, .Top, .Left, .Right, .TopLeft, .TopRight, .BottomLeft, .BottomRight]

