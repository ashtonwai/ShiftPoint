//
//  Player.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/3/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Player : SKSpriteNode {
    var prevPosition    : CGPoint = CGPointZero
    var rotateAngle     : CGFloat = 0
    var teleporting     : Bool = false
    var invincible      : Bool = false
    var autoFiring      : Bool = false
    var life            : Int = Config.Player.PLAYER_LIFE
    let maxLife         : Int = Config.Player.PLAYER_MAX_LIFE
    
    // MARK: - Initialization -
    init() {
        let texture = SKTexture(imageNamed: "Player")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.name = "player"
        self.size = size
        self.anchorPoint.y = 0.35
        
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
    
    
    // MARK: - Movement Controls -
    func direction(dx: CGFloat, dy: CGFloat) {
        let angle = atan2(dy, dx)
        rotateAngle = angle + CGFloat(M_PI/2)
        let rotate = SKAction.rotateToAngle(rotateAngle, duration: 0.0)
        self.runAction(rotate)
    }
    
    
    // MARK: - Event Handler -
    func onDamaged() {
        if Config.Developer.GodMode {
            return
        }
        
        life -= 1
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
    
    func onDestroy() {
        self.removeFromParent()
    }
}
