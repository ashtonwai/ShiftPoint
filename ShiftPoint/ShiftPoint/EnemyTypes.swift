//
//  EnemyTypes.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 5/8/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

enum EnemyTypes {
    case Bouncer
    case Seeker
    case NinjaStar
}

func createEnemy(enemyType: EnemyTypes, location: CGPoint) -> Enemy {
    var enemy: Enemy
    
    switch enemyType {
    case .Bouncer:
        enemy = Bouncer(pos: location)
        break
    case .Seeker:
        enemy = Seeker(pos: location)
        break
    case .NinjaStar:
        enemy = NinjaStar(pos: location)
        break;
    }
    
    return enemy
}