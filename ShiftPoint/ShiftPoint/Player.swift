//
//  Player.swift
//  ShiftPoint
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
    
    let teleportSound: SKAction = SKAction.playSoundFileNamed("Teleport.mp3", waitForCompletion: false)
    let bulletFireSound: SKAction = SKAction.playSoundFileNamed("Laser.mp3", waitForCompletion: false)
    
    
    // MARK: - Initialization -
    init() {
        let texture = SKTexture(imageNamed: "Player")
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        
        self.name = "player"
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
    func onTeleport(location: CGPoint) {
        let teleport = SKAction.sequence([
            SKAction.group([
                teleportSound,
                SKAction.runBlock() {
                    self.teleporting = true
                    self.prevPosition = self.position
                    self.runAction(SKAction.fadeOutWithDuration(0.5))
                    
                    let teleportOut = SKSpriteNode(imageNamed: "teleport_1")
                    teleportOut.position = self.prevPosition
                    teleportOut.zPosition = Config.GameLayer.Animation
                    teleportOut.zRotation = self.rotateAngle
                    self.parent!.addChild(teleportOut)
                    
                    teleportOut.runAction(SKAction.sequence([
                        self.teleportOutAnimation(),
                        SKAction.removeFromParent()
                    ]))
                }
            ]),
            SKAction.waitForDuration(0.25),
            SKAction.runBlock() {
                self.position = location
                self.runAction(SKAction.fadeInWithDuration(0.5))
                
                let teleportIn = SKSpriteNode(imageNamed: "teleport_6")
                teleportIn.position = self.position
                teleportIn.zPosition = Config.GameLayer.Animation
                teleportIn.zRotation = self.rotateAngle
                self.parent!.addChild(teleportIn)
                
                teleportIn.runAction(SKAction.sequence([
                    self.teleportInAnimation(),
                    SKAction.removeFromParent()
                ]))
                
                self.teleporting = false
            }
        ])
        self.runAction(teleport)
    }
    
    func onAutoFire() {
        if !invincible && !teleporting && !autoFiring {
            autoFiring = true
            runAction(SKAction.repeatActionForever(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.runBlock() {
                            let bullet = Bullet(circleOfRadius: 10)
                            bullet.position = CGPointMake(self.position.x, self.position.y)
                            bullet.zPosition = Config.GameLayer.Sprite
                            self.parent!.addChild(bullet)
                            
                            let dx = cos(self.zRotation + CGFloat(π/2))
                            let dy = sin(self.zRotation + CGFloat(π/2))
                            bullet.move(dx, dy: dy)
                        },
                        bulletFireSound
                    ]),
                    SKAction.waitForDuration(NSTimeInterval(Config.Player.FIRE_RATE))
                ])
            ), withKey: "autoFire")
        }
    }
    
    func stopAutoFire() {
        autoFiring = false
        removeActionForKey("autoFire")
    }
    
    func onDamaged() -> Bool {
        if Config.Developer.GodMode || invincible || teleporting {
            return false
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
        
        return true
    }
    
    func onDestroy() {
        self.removeFromParent()
    }
    
    
    // MARK: - Animations -
    func teleportOutAnimation() -> SKAction {
        var teleportOutTextures: [SKTexture] = []
        for i in 2...6 {
            teleportOutTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
        }
        return SKAction.animateWithTextures(teleportOutTextures, timePerFrame: 0.1)
    }
    
    func teleportInAnimation() -> SKAction {
        var teleportInTextures: [SKTexture] = []
        for i in 4.stride(to: 1, by: -1) {
            teleportInTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
        }
        return SKAction.animateWithTextures(teleportInTextures, timePerFrame: 0.1)
    }
}
