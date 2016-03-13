//
//  Animations.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/12/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

func anim_TeleportOut() -> SKAction {
    var teleportOutTextures: [SKTexture] = []
    for i in 2...6 {
        teleportOutTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
    }
    return SKAction.animateWithTextures(teleportOutTextures, timePerFrame: 0.1)
}

func anim_TeleportIn() -> SKAction {
    var teleportInTextures: [SKTexture] = []
    for var i = 4; i > 0; i-- {
        teleportInTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
    }
    return SKAction.animateWithTextures(teleportInTextures, timePerFrame: 0.1)
}