//
//  PowerUp.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 8/31/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class PowerUp: SKSpriteNode {
    var powerType: PowerTypes
    var powerName: String
    var powerScore: Int
    var enemyCount: Int
    var powerTime: Int
    
    var timer: Timer?
    var remainTime: Int = 0
    var active: Bool = true
    var ninjas: [NinjaStar] = []
    
    let pickUpSound: SKAction = SKAction.playSoundFileNamed("PickUp.wav", waitForCompletion: false)
    
    // MARK: - Initialization -
    init(texture: SKTexture, powerType: PowerTypes, powerName: String, powerScore: Int, enemyCount: Int, powerTime: Int) {
        self.powerType = powerType
        self.powerName = powerName
        self.powerScore = powerScore
        self.enemyCount = enemyCount
        self.powerTime = powerTime
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width/2)
        self.physicsBody?.categoryBitMask = PhysicsCategory.PowerUp
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        remainTime = powerTime
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Particles -
    func powerMarker() -> SKLabelNode {
        let powerMarker = SKLabelNode(fontNamed: Config.Font.MainFont)
        powerMarker.verticalAlignmentMode = .center
        powerMarker.fontColor = UIColor.yellow
        powerMarker.fontSize = 30
        powerMarker.text = "\(powerName)"
        powerMarker.position = self.position
        powerMarker.zPosition = Config.GameLayer.Sprite
        return powerMarker
    }
    
    
    // MARK: - Event Handlers -
    func countdown() {
        if remainTime > 1 {
            remainTime -= 1
            if remainTime < powerTime / 2 {
                run(SKAction.group([
                    SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                    glowAnimation(),
                    SKAction.run() {
                        for ninja in self.ninjas {
                            ninja.rotate(1.5)
                        }
                    }
                    ]))
            } else if remainTime < powerTime / 3 {
                run(SKAction.group([
                    SKAction.fadeAlpha(to: 0.25, duration: 0.5),
                    SKAction.run() {
                        for ninja in self.ninjas {
                            ninja.rotate(1.0)
                        }
                    }
                    ]))
            }
        } else {
            timer!.invalidate()
            run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.run() {
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
    
    func onPickUp(_ player: Player) {
        timer!.invalidate()
        run(pickUpAnimation())
        boost(player)
    }
    
    func boost(_ player: Player) {
        fatalError("Must override!")
    }
    
    
    // MARK: - Animations -
    func glowAnimation() -> SKAction {
        let glow = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(by: 0.05, duration: 0.5),
            SKAction.fadeAlpha(to: self.alpha + 0.05, duration: 0.25)
        ]))
        return glow
    }
    
    func pickUpAnimation() -> SKAction {
        let pickUp = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.run() {
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
