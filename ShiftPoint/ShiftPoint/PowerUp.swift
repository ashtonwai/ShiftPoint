//
//  PowerUp.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 8/31/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class PowerUp : SKSpriteNode {
    var powerType: PowerTypes
    var powerName: String
    var enemyCount: Int
    var powerTime: Int
    
    var timer: NSTimer?
    var remainTime: Int = 0
    var active: Bool = true
    var ninjas: [NinjaStar] = []
    
    // MARK: - Initialization -
    init(texture: SKTexture, powerType: PowerTypes, powerName: String, enemyCount: Int, powerTime: Int) {
        self.powerType = powerType
        self.powerName = powerName
        self.enemyCount = enemyCount
        self.powerTime = powerTime
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        self.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        remainTime = powerTime
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Particles -
    func powerMarker() -> SKLabelNode {
        let powerMarker = SKLabelNode(fontNamed: Config.Font.MainFont)
        powerMarker.fontColor = UIColor.yellowColor()
        powerMarker.fontSize = 30
        powerMarker.text = "\(powerName)"
        powerMarker.position = self.position
        powerMarker.zPosition = Config.GameLayer.Sprite
        return powerMarker
    }
    
    
    // MARK: - Helper Functions -
    func countdown() {
        if remainTime > 1 {
            remainTime -= 1
            if remainTime < powerTime / 2 {
                runAction(SKAction.group([
                    SKAction.fadeAlphaTo(0.5, duration: 0.5),
                    glowAnimation(),
                    SKAction.runBlock() {
                        for ninja in self.ninjas {
                            ninja.rotate(1.5)
                        }
                    }
                ]))
            } else if remainTime < powerTime / 3 {
                runAction(SKAction.group([
                    SKAction.fadeAlphaTo(0.25, duration: 0.5),
                    SKAction.runBlock() {
                        for ninja in self.ninjas {
                            ninja.rotate(1.0)
                        }
                    }
                ]))
            }
        } else {
            timer!.invalidate()
            runAction(SKAction.sequence([
                SKAction.fadeOutWithDuration(1.0),
                SKAction.runBlock() {
                    self.remainTime -= 1
                    self.active = false
                    for ninja in self.ninjas {
                        ninja.slash(self.position)
                    }
                },
                SKAction.removeFromParent()
            ]))
        }
    }
    
    
    // MARK: - Event Handlers -
    func onPickUp(player: Player) {
        timer!.invalidate()
        active = false
        runAction(SKAction.group([
            pickUpAnimation(),
            SKAction.runBlock() {
                self.boost(player)
            }
        ]))
    }
    
    func boost(player: Player) {
        fatalError("Must override!")
    }
    
    
    // MARK: - Animations -
    func glowAnimation() -> SKAction {
        let glow = SKAction.repeatActionForever(SKAction.sequence([
            SKAction.fadeAlphaBy(0.05, duration: 0.5),
            SKAction.fadeAlphaTo(self.alpha + 0.05, duration: 0.25)
        ]))
        return glow
    }
    
    func pickUpAnimation() -> SKAction {
        let pickUp = SKAction.sequence([
            SKAction.group([
                SKAction.scaleTo(3, duration: 0.5),
                SKAction.fadeOutWithDuration(0.5),
                SKAction.runBlock() {
                    for ninja in self.ninjas {
                        ninja.slash(self.position)
                    }
                }
            ]),
            SKAction.removeFromParent()
        ])
        return pickUp
    }
}
