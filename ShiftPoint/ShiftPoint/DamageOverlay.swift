//
//  DamageOverlay.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 9/29/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class DamageOverlay: SKSpriteNode {
    var duration: TimeInterval = Config.Player.PLAYER_DAMAGE_DURATION
    
    // MARK: - Initialization -
    init(size: CGSize) {
        self.duration += duration / 2
        
        let overlay = SKTexture(imageNamed: "DamageOverlay")
        super.init(texture: overlay, color: UIColor.clear, size: size)
        
        self.name = "damageOverlay"
        self.position = CGPoint(x: size.width/2, y: size.height/2)
        self.zPosition = Config.GameLayer.Overlay
        self.alpha = 0.8
        
        fadeOutOverlay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Animations -
    func fadeOutOverlay() {
        self.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: duration),
            SKAction.removeFromParent()
        ]))
    }
}
