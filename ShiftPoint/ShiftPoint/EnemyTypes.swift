//
//  EnemyTypes.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 5/8/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

enum EnemyTypes {
    case bouncer
    case seeker
    case ninjaStar
}

func createEnemy(_ enemyType: EnemyTypes, location: CGPoint, gameScene: GameScene) -> Enemy {
    var enemy: Enemy
    
    switch enemyType {
    case .bouncer:
        enemy = Bouncer(pos: location, gameScene: gameScene)
        break
    case .seeker:
        enemy = Seeker(pos: location, gameScene: gameScene)
        break
    case .ninjaStar:
        enemy = NinjaStar(pos: location, gameScene: gameScene)
        break;
    }
    
    return enemy
}
