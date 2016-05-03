//
//  Actions.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/12/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

let bulletFireSound: SKAction = SKAction.playSoundFileNamed("Laser.mp3", waitForCompletion: false)
let teleportSound: SKAction = SKAction.playSoundFileNamed("Teleport.mp3", waitForCompletion: false)
let scoreSound: SKAction = SKAction.playSoundFileNamed("Score.mp3", waitForCompletion: false)

func anim_TeleportOut() -> SKAction {
    var teleportOutTextures: [SKTexture] = []
    for i in 2...6 {
        teleportOutTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
    }
    return SKAction.animateWithTextures(teleportOutTextures, timePerFrame: 0.1)
}

func anim_TeleportIn() -> SKAction {
    var teleportInTextures: [SKTexture] = []
    for i in 4.stride(to: 1, by: -1) {
        teleportInTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
    }
    return SKAction.animateWithTextures(teleportInTextures, timePerFrame: 0.1)
}