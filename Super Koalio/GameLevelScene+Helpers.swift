//
//  GameLevelScene+Extension.swift
//  Super Koalio
//
//  Created by JackieDog on 6/21/17.
//  Copyright © 2017 JackieDog. All rights reserved.
//

import SpriteKit

extension GameLevelScene {
  
  /// Takes a tile's coordinates from a SKTileMapNode and returns the rect in pixel coordinates.
  func tileRect(in tileMap: SKTileMapNode, at tileCoords: TileCoordinates) -> CGRect {
    let tileWidth = tileMap.tileSize.width
    let tileHeight = tileMap.tileSize.height
    //let levelHeightInPixels = tileMap.mapSize.height * tileHeight
    let origin = CGPoint(x: CGFloat(tileCoords.column) * tileWidth, y: CGFloat(tileCoords.row) * tileHeight)
    //let origin = CGPoint(x: CGFloat(tileCoords.column) * tileWidth,
    //                     y: levelHeightInPixels - (CGFloat(tileCoords.row + 1) * tileHeight))
    
    return CGRect(x: origin.x, y: origin.y, width: tileWidth, height: tileHeight)
  }
  
  /// Returns the row and column coordinates for a given position.
  func tileCoordinates(in tileMap: SKTileMapNode, at position: CGPoint) -> TileCoordinates {
    let column = tileMap.tileColumnIndex(fromPosition: position)
    let row = tileMap.tileRowIndex(fromPosition: position)
    return (column, row)
  }
  
  /// Returns a tile definition from a SKTileMapNode at a column-row coordinate.
  func tile(in tileMap: SKTileMapNode, at tileCoords: TileCoordinates) -> SKTileDefinition? {
    return tileMap.tileDefinition(atColumn: tileCoords.column, row: tileCoords.row)
  }
}
