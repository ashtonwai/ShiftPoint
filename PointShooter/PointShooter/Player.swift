//
//  Player.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/3/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

class Player : SKSpriteNode {
    init(xScale: CGFloat, yScale: CGFloat) {
        let texture = SKTexture(imageNamed: "Player")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.size = size
        self.xScale = xScale
        self.yScale = yScale
        self.anchorPoint.y = 0.36
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(
            width: texture.size().width * xScale,
            height: texture.size().height * yScale))
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func direction(dx: CGFloat, dy: CGFloat) {
        let angle = atan2(dy, dx)
        let rotate = SKAction.rotateToAngle(angle + CGFloat(M_PI/2), duration: 0.0)
        self.runAction(rotate)
    }
}