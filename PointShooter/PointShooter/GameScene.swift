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
    static let Enemy     : UInt32 = 0b1 // 1
    static let Bullet    : UInt32 = 0b10 // 2
    static let Player    : UInt32 = 0b101 // 4
}

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    var gameManager: GameManager
    var gamePaused: Bool
    
    // Bounding boxes
    let playableRect: CGRect
    let spawnRectBounds: CGRect
    var spawnRects: [CGRect]
    
    // Enemy count handling
    var numOfEnemies = 0 //Config.GameLimit.MAX_BOUNCER
    let maxEnemySize = CGSize(width: 100, height: 100)
    
    // Player variables
    var player: Player!
    var lastUpdateTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    let fireRate: Float = Config.Player.FIRE_RATE
    var fireTimer: Float = 0.0
    
    // Game variables
    var pauseOverlay: SKShapeNode
    var pauseLabel = SKLabelNode(fontNamed: Config.Font.GameOverFont)
    var resumeButton = SKLabelNode(fontNamed: Config.Font.MainFont)
    var lifeLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    var scoreLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    var score = 0
    var highScore = 0
    var wave = 1
    
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode: SKSceneScaleMode, gameManager: GameManager) {
        self.gameManager = gameManager
        self.gamePaused = false
        self.pauseOverlay = SKShapeNode(rectOfSize: size)
        
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
        
        fireTimer = fireRate
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        playBackgroundMusic("BGM.mp3")
        setupWorld()
        setupHUD()
        spawnWave()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(GameScene.panDetected(_:)))
        self.view!.addGestureRecognizer(panGesture)
        
        // debug mode
        if Config.Developer.DebugMode {
            debugDrawPlayableArea()
        }
    }
    
    // MARK - Update -
    override func update(currentTime: CFTimeInterval) {
        if !gamePaused {
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
    }
    
    
    // MARK: - Event Handlers -
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if nodeAtPoint(location) == resumeButton {
                resumeButton.fontColor = UIColor.cyanColor()
            }
            
            let teleport = SKAction.sequence([
                SKAction.group([
                    teleportSound,
                    SKAction.runBlock() {
                        self.player.teleporting = true
                        self.player.prevPosition = self.player.position
                        self.player.runAction(SKAction.fadeOutWithDuration(0.5))
                        
                        let teleportOut = SKSpriteNode(imageNamed: "teleport_1")
                        teleportOut.position = self.player.prevPosition
                        teleportOut.zPosition = Config.GameLayer.Animation
                        teleportOut.zRotation = self.player.rotateAngle
                        self.addChild(teleportOut)
                        
                        teleportOut.runAction(SKAction.sequence([
                            teleportOutAnimation,
                            SKAction.removeFromParent()
                        ]))
                    }
                ]),
                SKAction.waitForDuration(0.25),
                SKAction.runBlock() {
                    self.player.position = location
                    self.player.runAction(SKAction.fadeInWithDuration(0.5))
                    
                    let teleportIn = SKSpriteNode(imageNamed: "teleport_6")
                    teleportIn.position = self.player.position
                    teleportIn.zPosition = Config.GameLayer.Animation
                    teleportIn.zRotation = self.player.rotateAngle
                    self.addChild(teleportIn)
                    
                    teleportIn.runAction(SKAction.sequence([
                        teleportInAnimation,
                        SKAction.removeFromParent()
                    ]))
                    
                    self.player.teleporting = false
                }
            ])
            
            if !gamePaused {
                self.runAction(teleport)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) { 
        for touch: AnyObject in touches {
            if nodeAtPoint(touch.locationInNode(self)) == resumeButton {
                resumeButton.fontColor = UIColor.whiteColor()
                runUnpauseAction()
            }
        }
    }
    
    func panDetected(recognizer: UIPanGestureRecognizer) {
        if !gamePaused {
            if recognizer.state == .Changed {
                var touchLocation = recognizer.locationInView(recognizer.view)
                touchLocation = self.convertPointFromView(touchLocation)
                
                let dy = player.position.y - touchLocation.y
                let dx = player.position.x - touchLocation.x
                player.direction(dx, dy: dy)
                
                if !player.invincible && !player.teleporting {
                    player.autoFiring = true
                }
            }
            if recognizer.state == .Ended {
                player.autoFiring = false
            }
        }
    }
    
    
    // MARK - Collision Detections -
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
            bulletDidCollideWithEnemy(firstBody.node as! Enemy, thisBullet: secondBody.node as! Bullet)
        }
        
        // enemy & player collision
        if (firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0) {
            playerDidCollideWithEnemy(firstBody.node as! Enemy, thisPlayer: secondBody.node as! Player)
        }
    }
    
    func bulletDidCollideWithEnemy(thisEnemy: Enemy, thisBullet: Bullet) {
        // emitter
        let emitter = thisEnemy.explosion()
        emitter.position = thisEnemy.position
        emitter.zPosition = Config.GameLayer.Sprite
        
        // points
        let pointsLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
        pointsLabel.position = thisEnemy.position
        pointsLabel.zPosition = Config.GameLayer.Sprite
        pointsLabel.fontColor = UIColor.cyanColor()
        pointsLabel.fontSize = 30
        pointsLabel.text = "\(thisEnemy.scorePoints)"
        
        runAction(SKAction.sequence([
            SKAction.group([
                scoreSound,
                SKAction.runBlock() {
                    self.addChild(emitter)
                    self.addChild(pointsLabel)
                    
                    thisBullet.onHit()
                    thisEnemy.onDamaged()
                    
                    self.score += thisEnemy.scorePoints
                    self.scoreLabel.text = "\(self.score)"
                    
                    self.numOfEnemies -= 1
                    if self.numOfEnemies <= 0 {
                        self.wave += 1
                        self.spawnWave()
                    }
                }
            ]),
            SKAction.waitForDuration(0.3),
            SKAction.runBlock() {
                emitter.removeFromParent()
                pointsLabel.runAction(SKAction.sequence([
                    SKAction.fadeOutWithDuration(0.5),
                    SKAction.removeFromParent()
                ]))
            }
        ]))
        
    }
    
    func playerDidCollideWithEnemy(thisEnemy: Enemy, thisPlayer: Player) {
        if !player.invincible && !player.teleporting {
            thisEnemy.onDestroy()
            player.onDamaged()
            lifeLabel.text = "Life: \(player.life)"
            
            if player.life <= 0 && !Config.Developer.Endless {
                player.onDestroy()
                gameOver()
                return
            }
            
            numOfEnemies -= 1
            if numOfEnemies <= 0 {
                wave += 1
                spawnWave()
            }
        }
    }
    
    
    // MARK: - Game Pausing -
    var gameActive: Bool = true {
        didSet {
            lastUpdateTime = 0
            deltaTime = 0
            if !gameActive {
                runPauseAction()
            }
        }
    }
    
    func runPauseAction() {
        // pause game
        gamePaused = true
        backgroundMusicPlayer.pause()
        pauseScreen()
        self.view?.paused = true
    }
    
    func runUnpauseAction() {
        // unpause game
        runAction(SKAction.sequence([
            SKAction.group([
                SKAction.runBlock() {
                    self.pauseLabel.runAction(SKAction.sequence([
                        SKAction.fadeOutWithDuration(0.5),
                        SKAction.removeFromParent()
                    ]))
                },
                SKAction.runBlock() {
                    self.resumeButton.runAction(SKAction.sequence([
                        SKAction.fadeOutWithDuration(0.5),
                        SKAction.removeFromParent()
                    ]))
                },
                SKAction.runBlock() {
                    self.pauseOverlay.runAction(SKAction.sequence([
                        SKAction.fadeOutWithDuration(1.0),
                        SKAction.removeFromParent()
                    ]))
                }
            ]),
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                self.gamePaused = false
                backgroundMusicPlayer.play()
                self.view?.paused = false
            }
        ]))
    }
    
    
    // MARK: - Helper Functions -
    func setupWorld() {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "Background.jpg")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Config.GameLayer.Background
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        player = Player()
        player.name = "player"
        player.position = CGPointMake(size.width/2, size.height/2)
        player.zPosition = Config.GameLayer.Sprite
        addChild(player)
    }
    
    func setupHUD() {
        let scoreTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
        scoreTextLabel.position = CGPointMake(50, size.height-50)
        scoreTextLabel.zPosition = Config.GameLayer.HUD
        scoreTextLabel.horizontalAlignmentMode = .Left
        scoreTextLabel.verticalAlignmentMode = .Top
        scoreTextLabel.fontColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        scoreTextLabel.fontSize = 50
        scoreTextLabel.text = "Score"
        addChild(scoreTextLabel)
        
        scoreLabel.position = CGPoint(x: 50, y: size.height-100)
        scoreLabel.zPosition = Config.GameLayer.HUD
        scoreLabel.horizontalAlignmentMode = .Left
        scoreLabel.verticalAlignmentMode = .Top
        scoreLabel.fontColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        scoreLabel.fontSize = 80
        scoreLabel.text = "\(score)"
        addChild(scoreLabel)
        
        lifeLabel.position = CGPoint(x: size.width-50, y: size.height-50)
        lifeLabel.zPosition = Config.GameLayer.HUD
        lifeLabel.horizontalAlignmentMode = .Right
        lifeLabel.verticalAlignmentMode = .Top
        lifeLabel.fontColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        lifeLabel.fontSize = 80
        lifeLabel.text = "Life: \(player.life)"
        addChild(lifeLabel)
    }
    
    func pauseScreen() {
        pauseOverlay.position = CGPointMake(size.width/2, size.height/2)
        pauseOverlay.zPosition = Config.GameLayer.Overlay
        pauseOverlay.fillColor = UIColor.blackColor()
        pauseOverlay.alpha = 0.75
        addChild(pauseOverlay)
        
        pauseLabel.position = CGPointMake(size.width/2, size.height/2+250)
        pauseLabel.zPosition = Config.GameLayer.Overlay
        pauseLabel.fontColor = UIColor.cyanColor()
        pauseLabel.fontSize = 200
        pauseLabel.text = "Paused"
        addChild(pauseLabel)
        
        resumeButton.position = CGPointMake(size.width/2, size.height/2-250)
        resumeButton.zPosition = Config.GameLayer.Overlay
        resumeButton.fontSize = 60
        resumeButton.text = "Resume"
        addChild(resumeButton)
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
        runAction(SKAction.group([
            SKAction.runBlock() {
                let bullet = Bullet(circleOfRadius: 10)
                bullet.position = CGPointMake(self.player.position.x, self.player.position.y)
                bullet.zPosition = Config.GameLayer.Sprite
                self.addChild(bullet)
                
                let dx = cos(self.player.zRotation + CGFloat(M_PI/2)) * 2500
                let dy = sin(self.player.zRotation + CGFloat(M_PI/2)) * 2500
                bullet.move(dx, dy: dy)
            },
            bulletFireSound
        ]))
    }
    
    func spawnWave() {
        // http://www.meta-calculator.com/online/9j13df5xtv8b
        var waveEnemyCount = Int(5.5 * sqrt(0.5 * Double(wave)))
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                if self.wave > 5 && self.wave % 3 == 0 {
                    self.spawnSeekerCircle()
                    waveEnemyCount /= 2
                }
                for _ in 0...waveEnemyCount-1 {
                    self.spawnBouncer()
                }
            }
        ]))
    }
    
    func spawnBouncer() {
        let bouncer = Bouncer(rectOfSize: CGSize(width: 50, height: 50))
        let spawnRect = spawnRects[Int.random(0...3)]
        bouncer.position = randomCGPointInRect(spawnRect, margin: maxEnemySize.width/2)
        bouncer.zPosition = Config.GameLayer.Sprite;
        bouncer.forward = CGPoint.randomUnitVector()
        addChild(bouncer)
        numOfEnemies += 1
    }
    
    func spawnSeeker() {
        print("seeker spawn!!")
        let seeker = Seeker(size: CGSize(width: 50, height: 50))
        let spawnRect = spawnRects[Int.random(0...3)]
        seeker.position = randomCGPointInRect(spawnRect, margin: maxEnemySize.width/2)
        seeker.zPosition = Config.GameLayer.Sprite
        addChild(seeker)
        numOfEnemies += 1
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
            seeker.zPosition = Config.GameLayer.Sprite
            addChild(seeker)
            numOfEnemies += 1
        }
    }
    
    func gameOver() {
        backgroundMusicPlayer.stop()
        gameManager.loadGameOverScene(score)
    }
    
    
    // MARK: - Debug -
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 10.0
        addChild(shape)
    }
}
