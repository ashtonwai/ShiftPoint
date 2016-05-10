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
}

func createEnemy(enemyType: EnemyTypes) -> Enemy {
    var enemy: Enemy
    
    switch enemyType {
    case .Bouncer:
        enemy = Bouncer()
        enemy.forward = CGPoint.randomUnitVector()
        break
    case .Seeker:
        enemy = Seeker()
        break
    }
    
    return enemy
}