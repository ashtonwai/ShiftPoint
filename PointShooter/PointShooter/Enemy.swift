//
//  Enemy.swift
//  PointShooter
//
//  Created by Ashton Wai on 5/7/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Enemy : SKShapeNode {
    var size: CGSize
    var scorePoints: Int
    var hitPoints: Int
    var typeColor: SKColor
    var forward: CGPoint = CGPointMake(0.0, 1.0)
    
    // MARK: - Initialization -
    init(size: CGSize, scorePoints: Int, hitPoints: Int, typeColor: SKColor) {
        self.size = size
        self.scorePoints = scorePoints
        self.hitPoints = hitPoints
        self.typeColor = typeColor
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Particles -
    func explosion() -> SKEmitterNode {
        let emitter = SKEmitterNode(fileNamed: "Explosion")!
        emitter.particleColorSequence = nil
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = typeColor
        return emitter
    }
    
    
    // MARK: - Event Handlers -
    func onDamaged() {
        hitPoints -= 1
        if hitPoints <= 0 {
            self.onDestroy()
        }
    }
    
    func onDestroy() {
        self.removeFromParent()
    }
}
