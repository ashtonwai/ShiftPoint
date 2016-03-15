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

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    // Bounding boxes
    let playableRect: CGRect
    let spawnRectBounds: CGRect
    var spawnRects: [CGRect]
    
    // Enemy count handling
    let numOfEnemies = Constants.Setup.MAX_BOUNCER
    let maxEnemySize = CGSize(width: 100, height: 100)
    
    // Player variables
    var player: Player!
    var lastUpdateTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    let fireRate: Float = Constants.Setup.FIRE_RATE
    var fireTimer: Float = 0.0
    
    let teleportOutAnimation: SKAction = anim_TeleportOut()
    let teleportInAnimation: SKAction = anim_TeleportIn()
    
    // Game variables
    var lifeLabel = SKLabelNode(fontNamed: Constants.Font.MainFont)
    var scoreLabel = SKLabelNode(fontNamed: Constants.Font.MainFont)
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
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        playBackgroundMusic("BGM.mp3")
        
        let background = SKSpriteNode(imageNamed: "Background.jpg")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Constants.GameLayer.Background
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        player = Player()
        player.name = "player"
        player.position = CGPointMake(size.width/2, size.height/2)
        player.zPosition = Constants.GameLayer.Sprite
        addChild(player)
        
        score = 0
        
        scoreLabel.position = CGPoint(x: 50, y: size.height - 50)
        scoreLabel.zPosition = Constants.GameLayer.HUD
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.fontColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        scoreLabel.fontSize = 80
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        lifeLabel.position = CGPoint(x: size.width - 50, y: size.height - 50)
        lifeLabel.zPosition = Constants.GameLayer.HUD
        lifeLabel.horizontalAlignmentMode = .Right
        lifeLabel.verticalAlignmentMode = .Top
        lifeLabel.fontColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        lifeLabel.fontSize = 80
        lifeLabel.text = "Life: \(player.health)"
        addChild(lifeLabel)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panDetected:"))
        self.view!.addGestureRecognizer(gestureRecognizer)
        
        fireTimer = fireRate
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                for _ in 0...self.numOfEnemies-1 {
                    self.spawnBouncer()
                }
                self.spawnSeekerCircle()
            }
        ]))
        
        // debug functions
        //debugDrawPlayableArea()
    }
    
    override func update(currentTime: CFTimeInterval) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        
        if (player.autoFiring) {
            if (fireTimer > 0) {
                fireTimer -= Float(deltaTime)
            } else {
                autoFire()
                fireTimer = fireRate
            }
        }
        
        enumerateChildNodesWithName("bouncer", usingBlock: { node, stop in
            let bouncer = node as! Bouncer
            bouncer.move(self.deltaTime)
            self.checkBounds(bouncer)
        })
        
        enumerateChildNodesWithName("seeker", usingBlock: { node, stop in
            let seeker = node as! Seeker
            if let targetLocation = self.player?.position {
                seeker.seek(self.deltaTime, location: targetLocation)
            }
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let teleport = SKAction.sequence([
                teleportSound,
                SKAction.runBlock() {
                    self.player.prevPosition = self.player.position
                    self.player.runAction(SKAction.fadeOutWithDuration(0.5))
                    self.player.invincible = true
                    
                    let teleportOut = SKSpriteNode(imageNamed: "teleport_1")
                    teleportOut.position = self.player.prevPosition
                    teleportOut.zPosition = Constants.GameLayer.Animation
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
                    self.player.invincible = false
                    
                    let teleportIn = SKSpriteNode(imageNamed: "teleport_6")
                    teleportIn.position = self.player.position
                    teleportIn.zPosition = Constants.GameLayer.Animation
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
        if recognizer.state == .Changed {
            var touchLocation = recognizer.locationInView(recognizer.view)
            touchLocation = self.convertPointFromView(touchLocation)
            
            let dy = player.position.y - touchLocation.y
            let dx = player.position.x - touchLocation.x
            player.direction(dx, dy: dy)
            
            if !player.invincible {
                player.autoFiring = true
            }
        }
        if recognizer.state == .Ended {
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
        if (firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet != 0) {
            bulletDidCollideWithEnemy(firstBody.node as! SKShapeNode, thisEnemy: secondBody.node as! SKShapeNode)
        }
        
        // player & enemy collision
        if (firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Enemy != 0) {
            playerDidCollideWithEnemy(firstBody.node as! SKShapeNode, thisPlayer: secondBody.node as! SKSpriteNode)
        }
    }
    
    func bulletDidCollideWithEnemy(thisBullet: SKShapeNode, thisEnemy: SKShapeNode) {
        runAction(scoreSound)
        
        /*
        // Emitter
        let effect = SKEffectNode() // Have it not blend with the background
        let emitter = SKEmitterNode(fileNamed: "Explosion")!
        emitter.position = CGPointMake(0,0)
        emitter.zPosition = 0
        effect.addChild(emitter)
        thisEnemy.addChild(effect)
        */
        
        thisBullet.removeFromParent()
        thisEnemy.removeFromParent()
        score += 10
        scoreLabel.text = "Score: \(score)"
        spawnBouncer()
    }
    
    func playerDidCollideWithEnemy(thisEnemy: SKShapeNode, thisPlayer: SKSpriteNode) {
        if !player.invincible {
            thisEnemy.removeFromParent()
            player.onDamaged()
            lifeLabel.text = "Life: \(player.health)"
            
            if player.health <= 0 {
                player.removeFromParent()
                gameOver()
            }
            
            spawnBouncer()
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
    
    func checkBounds(enemy: Bouncer) {
        var bounds : CGRect!
        
        if enemy.prevPosition < playableRect {
            // if visible on screen
            bounds = playableRect
        } else {
            // if intially spawning off-screen
            bounds = spawnRectBounds
        }
        
        // reflect velocity to stay in bounds
        if enemy.position.x <= bounds.minX {
            enemy.position.x = bounds.minX
            enemy.reflectX()
        }
        if enemy.position.x >= bounds.maxX {
            enemy.position.x = bounds.maxX
            enemy.reflectX()
        }
        if enemy.position.y <= bounds.minY {
            enemy.position.y = bounds.minY
            enemy.reflectY()
        }
        if enemy.position.y >= bounds.maxY {
            enemy.position.y = bounds.maxY
            enemy.reflectY()
        }
    }
    
    func autoFire() {
        let bullet = Bullet(circleOfRadius: 10)
        bullet.position = CGPointMake(player.position.x, player.position.y)
        bullet.zPosition = Constants.GameLayer.Sprite
        addChild(bullet)
        
        let dx = cos(player.zRotation + CGFloat(M_PI/2)) * 2500
        let dy = sin(player.zRotation + CGFloat(M_PI/2)) * 2500
        bullet.move(dx, dy: dy)
        
        runAction(bulletFireSound)
    }
    
    func spawnBouncer() {
        let bouncer = Bouncer(rectOfSize: CGSize(width: 50, height: 50))
        let spawnRect = spawnRects[Int.random(0...3)]
        bouncer.position = randomCGPointInRect(spawnRect, margin: maxEnemySize.width/2)
        bouncer.zPosition = Constants.GameLayer.Sprite;
        bouncer.forward = CGPoint.randomUnitVector()
        addChild(bouncer)
    }
    
    func spawnSeeker() {
        print("seeker spawn!!")
        let seeker = Seeker(size: CGSize(width: 50, height: 50))
        let spawnRect = spawnRects[Int.random(0...3)]
        seeker.position = randomCGPointInRect(spawnRect, margin: maxEnemySize.width/2)
        seeker.zPosition = Constants.GameLayer.Sprite
        addChild(seeker)
    }
    
    func spawnSeekerCircle () {
        for i in 0...16 {
            let angle = CGFloat(i) * 360.0 / 16.0
            let seeker = Seeker(size: CGSize(width: 75, height: 75))
            seeker.name = "seeker"
            seeker.position = CGPoint(
                x: playableRect.width/2 + playableRect.height/2 * cos(angle),
                y: playableRect.height/2 + playableRect.height/2 * sin(angle)
            )
            seeker.zPosition = Constants.GameLayer.Sprite
            addChild(seeker)
        }
    }
    
    func gameOver() {
        backgroundMusicPlayer.stop()
        let gameOverScene = GameOverScene(size: size)
        gameOverScene.scaleMode = scaleMode
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        view?.presentScene(gameOverScene, transition: reveal)
    }
}
