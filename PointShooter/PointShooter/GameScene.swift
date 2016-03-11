//
//  GameScene.swift
//  PointShooter
//
//  Created by Ashton Wai on 2/25/16.
//  Copyright (c) 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Enemy     : UInt32 = 0b1
    static let Bullet    : UInt32 = 0b10
    static let Player    : UInt32 = 0b101
}

struct GameLayer {
    static let Background   : CGFloat = 0
    static let Sprite       : CGFloat = 1
    static let Animation    : CGFloat = 2
    static let HUD          : CGFloat = 3
    static let Debug        : CGFloat = 4
}

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    let playableRect: CGRect
    let spawnRectBounds: CGRect
    var spawnRects: [CGRect]
    
    let numOfEnemies = 20
    let maxEnemySize = CGSize(width: 100, height: 100)
    
    var player: Player!
    var lastUpdateTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    let fireRate: Float = 0.1
    var fireTimer: Float = 0.0
    
    var teleportOutAnimation: SKAction
    var teleportInAnimation: SKAction
    
    var lifeLabel = SKLabelNode(fontNamed: "MicrogrammaDOT-MediumExtended")
    var scoreLabel = SKLabelNode(fontNamed: "MicrogrammaDOT-MediumExtended")
    var score = 0
    
    override init(size: CGSize) {
        // make constant for max aspect ratio support 4:3
        let maxAspectRatio: CGFloat = 4.0 / 3.0
        // calculate playable height
        let playableHeight = size.width / maxAspectRatio
        // center playable rectangle on the screen
        let playableMargin = (size.height - playableHeight) / 2.0
        // make centered rectangle on the screen
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        spawnRectBounds = CGRect(
            x: playableRect.minX - maxEnemySize.width,
            y: playableRect.minY - maxEnemySize.height,
            width: playableRect.width + maxEnemySize.width * 2,
            height: playableRect.height + maxEnemySize.height * 2
        )
        
        // create enemy spawn rects outside playable rect
        let topSpawnRect = CGRect(
            x: playableRect.minX - maxEnemySize.width,
            y: playableRect.maxY,
            width: playableRect.width + maxEnemySize.width * 2,
            height: maxEnemySize.height
        )
        let botSpawnRect = CGRect(
            x: playableRect.minX - maxEnemySize.width,
            y: playableRect.minY - maxEnemySize.height,
            width: playableRect.width + maxEnemySize.width * 2,
            height: maxEnemySize.height
        )
        let leftSpawnRect = CGRect(
            x: playableRect.minX - maxEnemySize.width,
            y: playableRect.minY - maxEnemySize.height,
            width: maxEnemySize.width,
            height: playableRect.height + maxEnemySize.height * 2
        )
        let rightSpawnRect = CGRect(
            x: playableRect.maxX,
            y: playableRect.minY - maxEnemySize.height,
            width: maxEnemySize.width,
            height: playableRect.height + maxEnemySize.height * 2
        )
        spawnRects = [topSpawnRect, botSpawnRect, leftSpawnRect, rightSpawnRect]
        
        // teleport-out animation
        var teleportOutTextures: [SKTexture] = []
        for i in 2...6 {
            teleportOutTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
        }
        teleportOutAnimation = SKAction.animateWithTextures(teleportOutTextures, timePerFrame: 0.1)
        
        // teleport-in animation
        var teleportInTextures: [SKTexture] = []
        for var i = 4; i > 0; i-- {
            teleportInTextures.append(SKTexture(imageNamed: "teleport_\(i)"))
        }
        teleportOutTextures.append(SKTexture(imageNamed: "teleport_6"))
        teleportInAnimation = SKAction.animateWithTextures(teleportInTextures, timePerFrame: 0.1)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "Background.jpg")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = GameLayer.Background
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        player = Player()
        player.name = "player"
        player.position = CGPointMake(size.width/2, size.height/2)
        player.zPosition = GameLayer.Sprite
        addChild(player)
        
        score = 0
        
        scoreLabel.position = CGPoint(x: 50, y: size.height - 50)
        scoreLabel.zPosition = GameLayer.HUD
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.fontColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        scoreLabel.fontSize = 80
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        lifeLabel.position = CGPoint(x: size.width - 50, y: size.height - 50)
        lifeLabel.zPosition = GameLayer.HUD
        lifeLabel.horizontalAlignmentMode = .Right
        lifeLabel.verticalAlignmentMode = .Top
        lifeLabel.fontColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        lifeLabel.fontSize = 80
        lifeLabel.text = "Life: \(player.lives)"
        addChild(lifeLabel)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panDetected:"))
        self.view!.addGestureRecognizer(gestureRecognizer)
        
        fireTimer = fireRate
        
//        runAction(SKAction.sequence([
//            SKAction.waitForDuration(1.0),
//            SKAction.runBlock() {
//                for _ in 0...self.numOfEnemies-1 {
//                    self.spawnEnemy()
//                }
//            }
//        ]))
        
        spawnSeeker()
        
        // debug functions
        //debugDrawPlayableArea()
    }
    
    override func update(currentTime: CFTimeInterval) {
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if (player.autoFiring) {
            if (fireTimer > 0) {
                fireTimer -= Float(deltaTime)
            } else {
                autoFire()
                fireTimer = fireRate
            }
        }
        
        enumerateChildNodesWithName("enemy", usingBlock: { node, stop in
            let enemy = node as! Enemy
            enemy.update(currentTime)
            self.checkBounds(enemy)
        })
        
        enumerateChildNodesWithName("seeker", usingBlock: { node, stop in
            let seeker = node as! Seeker
            if let targetLocation = self.player?.position {
                seeker.seek(currentTime, location: targetLocation)
            }
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let teleport = SKAction.sequence([
                SKAction.runBlock() {
                    self.player.prevPosition = self.player.position
                    self.player.runAction(SKAction.fadeOutWithDuration(0.5))
                    
                    let teleportOut = SKSpriteNode(imageNamed: "teleport_1")
                    teleportOut.position = self.player.prevPosition
                    teleportOut.zPosition = GameLayer.Animation
                    teleportOut.zRotation = self.player.rotateAngle
                    self.addChild(teleportOut)
                    
                    teleportOut.runAction(SKAction.sequence([
                        self.teleportOutAnimation,
                        SKAction.runBlock() {
                            teleportOut.removeFromParent()
                        }
                    ]))
                },
                SKAction.waitForDuration(0.25),
                SKAction.runBlock() {
                    self.player.position = location
                    self.player.runAction(SKAction.fadeInWithDuration(0.5))
                    
                    let teleportIn = SKSpriteNode(imageNamed: "teleport_1")
                    teleportIn.position = self.player.position
                    teleportIn.zPosition = GameLayer.Animation
                    teleportIn.zRotation = self.player.rotateAngle
                    self.addChild(teleportIn)
                    
                    teleportIn.runAction(SKAction.sequence([
                        self.teleportInAnimation,
                        SKAction.runBlock() {
                            teleportIn.removeFromParent()
                        }
                    ]))
                }
            ])
            self.runAction(teleport)
        }
    }
    
    func panDetected(recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .Changed) {
            var touchLocation = recognizer.locationInView(recognizer.view)
            touchLocation = self.convertPointFromView(touchLocation)
            
            let dy = player.position.y - touchLocation.y
            let dx = player.position.x - touchLocation.x
            player.direction(dx, dy: dy)
            
            if !player.invincible {
                player.autoFiring = true
            }
        }
        if (recognizer.state == .Ended) {
            player.autoFiring = false
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard firstBody.node != nil else {
            return
        }
        guard secondBody.node != nil else {
            return
        }
        
        // enemy & bullet collision
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet != 0)) {
                bulletDidCollideWithEnemy(firstBody.node as! SKShapeNode, thisEnemy: secondBody.node as! SKShapeNode)
        }
        
        // player & enemy collison
        if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Enemy != 0)) {
                playerDidCollideWithEnemy(firstBody.node as! SKShapeNode, thisPlayer: secondBody.node as! SKSpriteNode)
        }
    }
    
    func bulletDidCollideWithEnemy(thisBullet: SKShapeNode, thisEnemy: SKShapeNode) {
        thisBullet.removeFromParent()
        thisEnemy.removeFromParent()
        score += 10
        scoreLabel.text = "Score: \(score)"
        spawnEnemy()
    }
    
    func playerDidCollideWithEnemy(thisEnemy: SKShapeNode, thisPlayer: SKSpriteNode) {
        if !player.invincible {
            thisEnemy.removeFromParent()
            player.onDamaged()
            lifeLabel.text = "LIFE: \(player.lives)"
            
            if player.lives <= 0 {
                player.removeFromParent()
                
                let gameOverScene = GameOverScene(size: size)
                gameOverScene.scaleMode = scaleMode
                let reveal = SKTransition.crossFadeWithDuration(1.5)
                view?.presentScene(gameOverScene, transition: reveal)
            }
        }
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 10.0
        addChild(shape)
    }
    
    func checkBounds(enemy: Enemy) {
        if (enemy.prevPosition < playableRect) {
            let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
            let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
            
            if enemy.position.x <= bottomLeft.x {
                enemy.position.x = bottomLeft.x
                enemy.reflectX()
            }
            if enemy.position.x >= topRight.x {
                enemy.position.x = topRight.x
                enemy.reflectX()
            }
            if enemy.position.y <= bottomLeft.y {
                enemy.position.y = bottomLeft.y
                enemy.reflectY()
            }
            if enemy.position.y >= topRight.y {
                enemy.position.y = topRight.y
                enemy.reflectY()
            }
        } else {
            let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(spawnRectBounds))
            let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(spawnRectBounds))
            
            if enemy.position.x <= bottomLeft.x {
                enemy.position.x = bottomLeft.x
                enemy.reflectX()
            }
            if enemy.position.x >= topRight.x {
                enemy.position.x = topRight.x
                enemy.reflectX()
            }
            if enemy.position.y <= bottomLeft.y {
                enemy.position.y = bottomLeft.y
                enemy.reflectY()
            }
            if enemy.position.y >= topRight.y {
                enemy.position.y = topRight.y
                enemy.reflectY()
            }

        }
    }
    
    func autoFire() {
        let bullet = Bullet(circleOfRadius: 10)
        bullet.position = CGPointMake(player.position.x, player.position.y)
        bullet.zPosition = GameLayer.Sprite
        addChild(bullet)
        
        let dx = cos(player.zRotation + CGFloat(M_PI/2)) * 2500
        let dy = sin(player.zRotation + CGFloat(M_PI/2)) * 2500
        bullet.move(dx, dy: dy)
    }
    
    func spawnEnemy() {
        let enemy = Enemy(rectOfSize: CGSize(width: 50, height: 50))
        enemy.name = "enemy"
        let spawnRect = spawnRects[Int.random(0...3)]
        enemy.position = randomCGPointInRect(spawnRect, margin: maxEnemySize.width/2)
        enemy.zPosition = GameLayer.Sprite;
        enemy.forward = CGPoint.randomUnitVector()
        addChild(enemy)
    }
    
    func spawnSeeker() {
        print("seeker spawn!!")
        let seeker = Seeker(size: CGSize(width: 50, height: 50))
        seeker.name = "seeker"
        let spawnRect = spawnRects[Int.random(0...3)]
        seeker.position = randomCGPointInRect(spawnRect, margin: maxEnemySize.width/2)
        seeker.zPosition = GameLayer.Sprite
        addChild(seeker)
    }
}
