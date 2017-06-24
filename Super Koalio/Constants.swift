//
//  Constants.swift
//  Super Koalio
//
//  Created by JackieDog on 6/20/17.
//  Copyright © 2017 JackieDog. All rights reserved.
//

import SpriteKit

struct Assets {
  struct Images {
    static let Replay = "replay"
  }
  
  struct Sounds {
    static let BGMusic = "level1.mp3"
    static let Jump = "jump.wav"
    static let Hurt = "hurt.wav"
  }
}

struct GameScenes {
  static let GameLevelScene = "GameLevelScene"
  static let Level1 = "Level1"
}

struct TileMaps {
  static let BgTileMap = "bgTileMap"
  static let WallsTileMap = "wallsTileMap"
  static let ObjectsTileMap = "objectsTileMap"
  static let HazardsTileMap = "hazardsTileMap"
}

struct Nodes {
  struct Names {
    static let World = "world"
    static let Player = "player"
  }
  
  struct zPositions {
    static let Player: CGFloat = 15
  }
}

struct Actions {
  struct Sounds {
    static let Jump = SKAction.playSoundFileNamed(Assets.Sounds.Jump, waitForCompletion: false)
    static let Hurt = SKAction.playSoundFileNamed(Assets.Sounds.Hurt, waitForCompletion: false)
  }
}
