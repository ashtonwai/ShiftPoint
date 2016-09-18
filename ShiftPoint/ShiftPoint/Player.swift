//
//  Player.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 3/3/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Player : SKSpriteNode {
    var prevPosition    : CGPoint = CGPoint.zero
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
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        self.name = "player"
        self.size = size
        self.anchorPoint.y = 0.35
        
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(
            width: texture.size().width * xScale,
            height: texture.size().height * yScale))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Movement Controls -
    func direction(_ dx: CGFloat, dy: CGFloat) {
        let angle = atan2(dy, dx)
        rotateAngle = angle + CGFloat(M_PI/2)
        let rotate = SKAction.rotate(toAngle: rotateAngle, duration: 0.0)
        self.run(rotate)
    }
    
    
    // MARK: - Event Handler -
    func onTeleport(_ location: CGPoint) {
        let teleport = SKAction.sequence([
            SKAction.group([
                teleportSound,
                SKAction.run() {
                    self.teleporting = true
                    self.prevPosition = self.position
                    self.run(SKAction.fadeOut(withDuration: 0.5))
                    
                    let teleportOut = SKSpriteNode(imageNamed: "teleport_1")
                    teleportOut.position = self.prevPosition
                    teleportOut.zPosition = Config.GameLayer.Animation
                    teleportOut.zRotation = self.rotateAngle
                    self.parent!.addChild(teleportOut)
                    
                    teleportOut.run(SKAction.sequence([
                        self.teleportOutAnimation(),
                        SKAction.removeFromParent()
                    ]))
                }
            ]),
            SKAction.wait(forDuration: 0.25),
            SKAction.run() {
                self.position = location
                self.run(SKAction.fadeIn(withDuration: 0.5))
                
                let teleportIn = SKSpriteNode(imageNamed: "teleport_6")
                teleportIn.position = self.position
                teleportIn.zPosition = Config.GameLayer.Animation
                teleportIn.zRotation = self.rotateAngle
                self.parent!.addChild(teleportIn)
                
                teleportIn.run(SKAction.sequence([
                    self.teleportInAnimation(),
                    SKAction.removeFromParent()
                ]))
                
                self.teleporting = false
            }
        ])
        self.run(teleport)
    }
    
    func onAutoFire() {
        if !invincible && !teleporting && !autoFiring {
            autoFiring = true
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.run() {
                            let bullet = Bullet(circleOfRadius: 10)
                            bullet.position = CGPoint(x: self.position.x, y: self.position.y)
                            bullet.zPosition = Config.GameLayer.Sprite
                            self.parent!.addChild(bullet)
                            
                            let dx = cos(self.zRotation + CGFloat(π/2))
                            let dy = sin(self.zRotation + CGFloat(π/2))
                            bullet.move(dx, dy: dy)
                        },
                        bulletFireSound
                    ]),
                    SKAction.wait(forDuration: TimeInterval(Config.Player.FIRE_RATE))
                ])
            ), withKey: "autoFire")
        }
    }
    
    func stopAutoFire() {
        autoFiring = false
        removeAction(forKey: "autoFire")
    }
    
    func onDamaged() {
        if Config.Developer.GodMode || invincible || teleporting {
            return
        }
        
        invincible = true
        autoFiring = false
        life -= 1
        
        let blinkTimes = 6.0
        let duration = 1.5
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        let setHidden = SKAction.run() {
            self.isHidden = false
            self.invincible = false
        }
        self.run(SKAction.sequence([blinkAction, setHidden]))
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
        return SKAction.animate(with: teleportOutTextures, timePerFrame: 0.1)
    }
    
    func teleportInAnimation() -> SKAction {
        var teleportInTextures: [SKTexture] = []
        for i in stride(from: 4, to: 1, by: -1) {
            teleportInTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
        }
        return SKAction.animate(with: teleportInTextures, timePerFrame: 0.1)
    }
}
