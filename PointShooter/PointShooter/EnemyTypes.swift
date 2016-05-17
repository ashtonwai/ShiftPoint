//
//  EnemyTypes.swift
//  PointShooter
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

func createEnemy(enemyType: EnemyTypes) -> Enemy {
    var enemy: Enemy
    
    switch enemyType {
    case .Bouncer:
        enemy = Bouncer()
        break
    case .Seeker:
        enemy = Seeker()
        break
    case .NinjaStar:
        enemy = NinjaStar()
        break;
    }
    
    return enemy
}