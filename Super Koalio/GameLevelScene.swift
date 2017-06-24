//
//  GameLevelScene.swift
//  Super Koalio
//
//  Created by JackieDog on 6/20/17.
//  Copyright © 2017 JackieDog. All rights reserved.
//

import SpriteKit

class GameLevelScene: SKScene {
  // MARK: - Properties
  private var lastUpdateTime: TimeInterval = 0
  private var dt: TimeInterval = 0
  
  private var playableRect: CGRect!
  
  private var world: SKNode!
  var bgTileMap: SKTileMapNode!
  var wallsTileMap: SKTileMapNode!
  var objectsTileMap: SKTileMapNode!
  var hazardsTileMap: SKTileMapNode!
  
  fileprivate var player: Player!
  fileprivate var isGameOver = false
  fileprivate var bottomPosition: CGFloat = 0.0
  
  // MARK: - Initializers
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    // Calculates the Playable Rect
    let maxAspectRatio: CGFloat = 16.0 / 9.0
    let playableHeight = size.width / maxAspectRatio
    let playableMargin = (size.height - playableHeight) / 2.0
    playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
  }
  
  // MARK: - DidMove
  override func didMove(to view: SKView) {
    setupNodes()
    setupMusic()
    setupCamera()
  }
  
  
  // MARK: - Setup
  /// Sets up the nodes
  func setupNodes() {
    guard let world       = childNode(withName: Nodes.Names.World),
      let bgTileMap       = world.childNode(withName: TileMaps.BgTileMap) as? SKTileMapNode,
      let wallsTileMap    = world.childNode(withName: TileMaps.WallsTileMap) as? SKTileMapNode,
      let objectsTileMap  = world.childNode(withName: TileMaps.ObjectsTileMap) as? SKTileMapNode,
      let hazardsTileMap  = world.childNode(withName: TileMaps.HazardsTileMap) as? SKTileMapNode,
      let player          = world.childNode(withName: Nodes.Names.Player) as? Player
      else { return }
    
    self.world = world
    self.bgTileMap = bgTileMap
    self.wallsTileMap = wallsTileMap
    self.objectsTileMap = objectsTileMap
    self.hazardsTileMap = hazardsTileMap
    self.player = player
    
    bottomPosition = wallsTileMap.position.y
    
    isUserInteractionEnabled = true
  }
  
  func setupMusic() {
    SKTAudio.sharedInstance().playBackgroundMusic(Assets.Sounds.BGMusic)
  }
  
  
  /// Sets up the camera so it follows the player and doesn't show the gray areas.
  func setupCamera() {
    // Checks that the scene has a camera assigned to it.
    guard let camera = camera else { return }
    
    // Create a constraint to keep zero distance to the player.
    let zeroDistance = SKRange(constantValue: 0)
    let playerConstraint = SKConstraint.distance(zeroDistance, to: player)
    
    // Determine the smallest distance from each edge that you can position the camera to avoid
    // showing the gray area. If the camera viewport is larger than the map (when it's imposible
    // to avoid showing the gray area), makes the map to appear centered.
    let xInset = min(playableRect.width  / 2 * camera.xScale, wallsTileMap.frame.width  / 2)
    let yInset = min(playableRect.height / 2 * camera.yScale, wallsTileMap.frame.height / 2)
    
    // Gets a rectangular boundary constraint.
    let constraintRect = wallsTileMap.frame.insetBy(dx: xInset, dy: yInset)
    
    // Sets up a constraint for x and y with lower and upper limits.
    let xRange = SKRange(lowerLimit: constraintRect.minX, upperLimit: constraintRect.maxX)
    let yRange = SKRange(lowerLimit: constraintRect.minY, upperLimit: constraintRect.maxY)
    
    let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
    
    // The node whose coordinate system should be used to apply the constraint.
    edgeConstraint.referenceNode = wallsTileMap
    
    // The camera will always follow the player and keep him centered onscreen. The edge
    // constraint has higher priority, so it goes last (otherwise, the gray area would still be shown).
    camera.constraints = [playerConstraint, edgeConstraint]
  }
  
  
  // MARK: - Win and Game Over
  func checkForWin() {
    let playerCoords = tileCoordinates(in: wallsTileMap, at: player.position)
    
    if playerCoords.column > 200 {
      gameOver(won: true)
    }
  }
  
  func gameOver(won: Bool) {
    guard let camera = camera, let view = view else { return }
    
    isGameOver = true
    
    if !won { run(Actions.Sounds.Hurt) }
    
    var gameText: String
    won ? (gameText = "You Won!") : (gameText = "You Have Died!")
    
    let endGameLabel = SKLabelNode(fontNamed: "Marker Felt")
    endGameLabel.text = gameText
    endGameLabel.fontSize = 100
    endGameLabel.position = CGPoint(x: 0, y: 200)
    camera.addChild(endGameLabel)
    
    guard let replayImg = UIImage(named: Assets.Images.Replay) else { return }
    let replayBtn = UIButton(type: .custom)
    replayBtn.tag = 321
    replayBtn.setImage(replayImg, for: .normal)
    replayBtn.addTarget(self, action: #selector(replay), for: .touchUpInside)
    replayBtn.frame = CGRect(x: view.frame.width / 2 - replayImg.size.width / 2,
                             y: view.frame.height / 2 - replayImg.size.height / 2,
                             width: replayImg.size.width,
                             height: replayImg.size.height)
    view.addSubview(replayBtn)
  }
  
  
  func replay(_ sender: UIButton) {
    guard let view = view,
      let scene = SKScene(fileNamed: GameScenes.Level1) as? GameLevelScene
      else { return }
    
    scene.scaleMode = scaleMode
    view.viewWithTag(321)?.removeFromSuperview()
    view.presentScene(scene, transition: SKTransition.flipVertical(withDuration: 0.5))
  }
  
  
  // MARK: - Update
  override func update(_ currentTime: TimeInterval) {
    guard !isGameOver else { return }
    
    // Delta Time
//    lastUpdateTime > 0 ? (dt = currentTime - lastUpdateTime) : (dt = 0)
    dt = currentTime - lastUpdateTime
    if dt > 0.02 { dt = 0.02 }
    lastUpdateTime = currentTime
    
    player.update(withDeltaTime: dt)
    
    checkForAndResolveCollisions(forPlayer: player)
    checkForWin()
  }
}


// MARK: - Colision Detection System
extension GameLevelScene {
  /// Checks collisions for all the diferent layers of tiles.
  ///
  /// - Parameter player: player to check collisions with.
  func checkForAndResolveCollisions(forPlayer player: Player) {
    player.isOnGround = false
    
    checkforCollisions(in: wallsTileMap)
    checkforCollisions(in: objectsTileMap)
    checkforCollisions(in: hazardsTileMap)
    
    // If the player reaches the bottom of the screen it's game over.
    if player.position.y < bottomPosition {
      gameOver(won: false)
    }
  }
  
  
  /// Guts of the collision detection system.
  ///
  /// The player is less than two tile widths (a tile is 16 points) high and two tile widths wide.
  /// This means that the player will only every be encroaching on a 3x3 grid of tiles that
  /// directly surround him. If his sprite were larger you'd need to look beyond that 3x3 grid,
  /// but to keep things simple, I'm keeping him small.
  ///
  /// For example, if the tileIndex is 3 (Left), the value in tileColumn would be 0 (3 % 3 = 0)
  /// and the value in tileRow would be 1 (3 / 3 = 1). If the player's position was found
  /// to be at tile coordinate 100, 18, then the surrounding tile at tileIndex 3 would be
  /// 100 + (0 - 1) and 18 + (1 - 1) or 99, 18, which is the tile directly to the left
  /// of the player's tile position.
  ///
  /// If the tileIndex is 7 (Down), ther value in tileColum would be 1 (7 % 3 = 1)
  /// and the value in tileRow would be 2 (7 / 3 = 1). If the player's position was found
  /// to be at tile coordinate 100, 18, then the surrounding tile at tileIndex 7 would be
  /// 100 + (1 - 1) and 18 + (1 - 2) or 100, 17, which is the tile directly below
  /// the player's tile position.
  ///
  /// - Parameters:
  ///   - tileMap: TileMap where to check collisions against tiles.
  func checkforCollisions(in tileMap: SKTileMapNode) {
    guard let tileMapName = tileMap.name else { return }
    
    for tileIndex in TileIndices {
      
      // The CGRect (in points) that will trigger a collision with the player.
      let playerBoundingBox = player.collisionBoundingBox()
      
      // Tile coordinate of the player's position. This is the starting place from which
      // you'll find the 8 other tile coordinates for the surrounding tiles.
      let playerCoords = tileCoordinates(in: tileMap, at: player.desiredPosition)
      
      // Finds the tile coordinate that is around the player's position
      let tileColumn = tileIndex.rawValue % 3
      let tileRow = tileIndex.rawValue / 3
      let tileCoords =
        (column: playerCoords.column + (tileColumn - 1), row: playerCoords.row + (1 - tileRow))
      
      // Checks if there's a tile in the Tile Map at those coordenates.
      if tile(in: tileMap, at: tileCoords) != nil {
        // Gets the CGRect (in points) for that tile.
        let tileBoundingBox = tileRect(in: tileMap, at: tileCoords)
        
        // Checks if the player's desired rectangle and the tile's rectangle intersect.
        if playerBoundingBox.intersects(tileBoundingBox) {
          switch tileMapName {
          case TileMaps.WallsTileMap, TileMaps.ObjectsTileMap:
            resolveCollisions(forPlayer: player, tileIndex: tileIndex, tileBoundingBox: tileBoundingBox)
          case TileMaps.HazardsTileMap:
            gameOver(won: false)
          default: break
          }
        }
      }
    }
    
    // Sets the position of the player to the final collision-detection resolved result.
    player.position = player.desiredPosition
  }
  
  
  
  /// Resolves the collision between the player an the tile he's collisioning with.
  ///
  /// - Parameters:
  ///   - player: player to check collisions
  ///   - tileIndex: the position of the tile the player is collisioning with.
  ///   - tileBoundingBox: the bounding box of the tile the player is collisioning with.
  func resolveCollisions(forPlayer player: Player, tileIndex: TilePositions,
                         tileBoundingBox: CGRect) {
    let playerBoundingBox = player.collisionBoundingBox()
    
    // Gets the overlapping section of the two CGRects.
    let intersection = playerBoundingBox.intersection(tileBoundingBox)
    
    switch tileIndex {
    case .Bottom: // Tile is directly below the player.
      player.desiredPosition =
        CGPoint(x: player.desiredPosition.x,
                y: player.desiredPosition.y + intersection.height)
      player.velocity = CGPoint(x: player.velocity.x, y: 0.0)
      player.isOnGround = true
      
    case .Top: // Tile is directly above the player.
      player.desiredPosition =
        CGPoint(x: player.desiredPosition.x,
                y: player.desiredPosition.y - intersection.height)
      player.velocity = CGPoint(x: player.velocity.x, y: 0.0)
      
    case .Left: // Tile is on left of the player.
      player.desiredPosition =
        CGPoint(x: player.desiredPosition.x + intersection.width,
                y: player.desiredPosition.y)
      
    case .Right: // Tile is on the right of the player.
      player.desiredPosition =
        CGPoint(x: player.desiredPosition.x - intersection.width,
                y: player.desiredPosition.y)
      
    default: // Tile is diagonal
      // Determines whether the collision is wide or tall.
      if intersection.width > intersection.height {
        // Resolves collision vertically (moving the player up or down)
        
        player.velocity = CGPoint(x: player.velocity.x, y: 0.0)
        let intersectionHeight: CGFloat
        
        if tileIndex == .BottomLeft  || tileIndex == .BottomRight {
          // Moves the player up
          intersectionHeight = intersection.height
          player.isOnGround = true
        } else { // .TopLeft or .TopRight
          // Moves the player down
          intersectionHeight = -intersection.height
        }
        
        player.desiredPosition =
          CGPoint(x: player.desiredPosition.x,
                  y: player.desiredPosition.y + intersectionHeight)
      } else {
        // Resolves collision horizontally (moving the player left or right)
        let intersectionWidth: CGFloat
        
        if tileIndex == .TopLeft || tileIndex == .BottomLeft {
          // Moves the player to the right
          intersectionWidth = intersection.width
        } else { // .TopRight or .BottomRight
          // Moves the player to the left
          intersectionWidth = -intersection.width
        }
        
        player.desiredPosition =
          CGPoint(x: player.desiredPosition.x + intersectionWidth,
                  y: player.desiredPosition.y)
      }
    }
  }
}



// MARK: - Touches
extension GameLevelScene {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let camera = camera else { return }
    
    for touch in touches {
      let touchLocation = convert(touch.location(in: self), to: camera)
      
      // The player moves forward by moving the left side of the screen
      // The player jumps by moving the right side of the screen
      touchLocation.x > 0 ? (player.jump = true) : (player.moveForward = true)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let camera = camera else { return }
    
    for touch in touches {
      let touchLocation = convert(touch.location(in: self), to: camera)
      let previousTouchLocation = convert(touch.previousLocation(in: self), to: camera)
      
      // Only changes the values if the touch crosses the middle of the screen.
      if touchLocation.x > 0, previousTouchLocation.x <= 0 {
        player.moveForward = false
        player.jump = true
      } else if touchLocation.x <= 0, previousTouchLocation.x > 0 {
        player.moveForward = true
        player.jump = false
      }
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let camera = camera else { return }
    for touch in touches {
      let touchLocation = convert(touch.location(in: self), to: camera)
      
      touchLocation.x < 0 ? (player.moveForward = false) : (player.jump = false)
    }
  }
}
