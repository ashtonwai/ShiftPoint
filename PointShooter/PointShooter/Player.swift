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
    var prevPosition : CGPoint = CGPointZero
    var invincible = false
    var lives = 5
    var autoFiring = false
    
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
    
    func onDamaged() {
        lives--
        invincible = true
        autoFiring = false
        
        let blinkTimes = 6.0
        let duration = 1.5
        let blinkAction = SKAction.customActionWithDuration(duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let setHidden = SKAction.runBlock() {
            self.hidden = false
            self.invincible = false
        }
        self.runAction(SKAction.sequence([blinkAction, setHidden]))
    }
}