//
//  Player.swift
//  Super Koalio
//
//  Created by JackieDog on 6/20/17.
//  Copyright © 2017 JackieDog. All rights reserved.
//

import SpriteKit

enum PlayerSettings {
  static let Gravity = CGPoint(x: 0.0, y: -3000)
  static let Friction = CGPoint(x: 0.9, y: 0.9)
  static let ForwardVelocity = CGPoint(x: 3000.0, y: 0.0)
  static let JumpForce = CGPoint(x: 0.0, y: 1800)
  static let JumpCutoff: CGFloat = 150.0
  static let MinMovement = CGPoint(x: 0.0, y: -1800.0)
  static let MaxMovement = CGPoint(x: 3000.0, y: 1800)
}


class Player: SKSpriteNode {
  // MARK: - Properties
  var velocity = CGPoint.zero
  var desiredPosition = CGPoint.zero
  var isOnGround = false
  
  var moveForward = false
  var jump = false
  
  /// Returns the bounding box of the player, which is his frame minus 2 points on each x-side,
  /// based on the desired position.
  func collisionBoundingBox() -> CGRect {
    let boundingBox = frame.insetBy(dx: 2, dy: 0)
    let diff = desiredPosition - position

    return boundingBox.offsetBy(dx: diff.x, dy: diff.y)
  }
  
  // MARK: - Update
  func update(withDeltaTime dt: TimeInterval) {
    // For each second in time, you’re accelerating the velocity of the player 450 points
    // towards the floor.
    let gravity = PlayerSettings.Gravity
    
    // Scales the acceleration down to the size fo the current time step.
    let gravityStep = gravity * dt
    
    let forwardMove = PlayerSettings.ForwardVelocity
    let forwardMoveStep = forwardMove * dt
    let friction = PlayerSettings.Friction
    
    velocity += gravityStep
    // When the force is removed, the player comes to a stop, byt not immediately.
    // By applying a 0.90 damping, we reduce the overall horizontal force by 10% each frame.
    velocity = CGPoint(x: velocity.x * friction.x, y: velocity.y)
    
    // Jumping
    ////// Old school Atari jumping. Every jump will be the same.
    ////// if jump, isOnGround { velocity += jumpForce }
    
    // Sonic-like jumping (sets up a minimum jump (jumpCutoff) and the longer the jump button
    // is pressed, the higher the player jumps, up to the maxMovement.y limit.
    let jumpForce = PlayerSettings.JumpForce
    let jumpCutoff = PlayerSettings.JumpCutoff
    
    if jump, isOnGround {
      velocity += jumpForce
      run(Actions.Sounds.Jump)
    } else if !jump, velocity.y > jumpCutoff {
      //velocity = CGPoint(x: velocity.x, y: jumpCutoff)
      velocity = CGPoint(x: velocity.x, y: velocity.y * friction.y)
    }
    
    // Moves forward
    if moveForward { velocity += forwardMoveStep }
    
    // Clamps the horizontal and vertical speeds.
    let minMovement = PlayerSettings.MinMovement
    let maxMovement = PlayerSettings.MaxMovement
    velocity = CGPoint(x: clamp(value: velocity.x, lower: minMovement.x, upper: maxMovement.x),
                       y: clamp(value: velocity.y, lower: minMovement.y, upper: maxMovement.y))
    
    let velocityStep = velocity * dt // Velocity for a single timestep.
    
    desiredPosition = position + velocityStep
  }
}
