//
//  LifeUp.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 8/31/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class LifeUp: PowerUp {
    let type: PowerTypes = PowerTypes.life
    let icon: SKTexture = Config.PowerUp.LifeUp.LIFEUP_ICON
    let label: String = Config.PowerUp.LifeUp.LIFEUP_NAME
    let count: Int = Config.PowerUp.LifeUp.LIFEUP_ENEMY_COUNT
    let time: Int = Config.PowerUp.LifeUp.LIFEUP_TIME
    
    // MARK: - Initialization -
    init(pos: CGPoint) {
        super.init(texture: icon, powerType: type, powerName: label, enemyCount: count, powerTime: time)
        
        self.name = "lifeUp"
        self.position = pos
        self.zPosition = Config.GameLayer.Sprite
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Event Handlers -
    override func boost(_ player: Player) -> Bool {
        if self.active && player.life < player.maxLife {
            self.active = false
            player.life += 1
            return true
        }
        return false
    }
}
