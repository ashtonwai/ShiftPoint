//
//  GameScene.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 2/25/16.
//  Copyright (c) 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

struct PhysicsCategory {
    static let None         : UInt32 = 0
    static let All          : UInt32 = UInt32.max
    static let OuterBounds  : UInt32 = 0b1 // 1
    static let PlayBounds   : UInt32 = 0b10 // 2
    static let Enemy        : UInt32 = 0b101 // 4
    static let Player       : UInt32 = 0b1001 // 8
    static let Bullet       : UInt32 = 0b10001 // 16
    static let PowerUp      : UInt32 = 0b100001 // 32
}

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    var gameManager         : GameManager
    var gamePaused          : Bool
    
    // Bounding boxes
    let playableRect        : CGRect
    let spawnRectBounds     : CGRect
    let spawnZoneBounds     : CGRect
    
    // Player variables
    var player              : Player!
    var lastUpdateTime      : CFTimeInterval = 0
    var deltaTime           : CFTimeInterval = 0
    
    // Game variables
    var pauseOverlay        : SKShapeNode
    var pauseLabel          : SKLabelNode
    var resumeButton        : SKLabelNode
    var scoreLabel          : SKLabelNode = SKLabelNode(fontNamed: Config.Font.MainFont)
    var waveLabel           : SKLabelNode = SKLabelNode(fontNamed: Config.Font.MainFont)
    let maxEnemySize        : CGSize = Config.Enemy.ENEMY_MAX_SIZE
    var numOfEnemies        : Int = 0
    var score               : Int = 0
    var wave                : Int = 1
    var lives               : [SKSpriteNode] = []
    
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode: SKSceneScaleMode, gameManager: GameManager) {
        self.gameManager = gameManager
        self.gamePaused = false
        self.pauseOverlay = SKShapeNode(rectOf: size)
        self.pauseLabel = SKLabelNode(fontNamed: Config.Font.GameOverFont)
        self.resumeButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        
        // make constant for max aspect ratio support 4:3
        let maxAspectRatio: CGFloat = 4.0 / 3.0
        // calculate playable height
        let playableHeight = size.width / maxAspectRatio
        // center playable rectangle on the screen
        let playableMargin = (size.height - playableHeight) / 2.0
        // make centered rectangle on the screen
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        // Spawn Rects
        spawnRectBounds = CGRect(
            x: playableRect.minX - maxEnemySize.width,
            y: playableRect.minY - maxEnemySize.height,
            width: playableRect.width + maxEnemySize.width * 2,
            height: playableRect.height + maxEnemySize.height * 2
        )
        spawnZoneBounds = CGRect(
            x: playableRect.minX - maxEnemySize.width/2,
            y: playableRect.minY - maxEnemySize.height/2,
            width: playableRect.width + maxEnemySize.width,
            height: playableRect.height + maxEnemySize.height
        )
        
        super.init(size: size)
        
        // Physics for Spawn Rects
        // OuterBounds
        let outerBoundingBox = SKShapeNode()
        outerBoundingBox.path = CGPath(rect: spawnRectBounds, transform: nil)
        outerBoundingBox.physicsBody = SKPhysicsBody(edgeLoopFrom: spawnRectBounds)
        outerBoundingBox.physicsBody?.categoryBitMask = PhysicsCategory.OuterBounds
        addChild(outerBoundingBox)
        
        // PlayBounds
        let boundingBox = SKShapeNode()
        boundingBox.path = CGPath(rect: playableRect, transform: nil)
        boundingBox.physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        boundingBox.physicsBody?.categoryBitMask = PhysicsCategory.PlayBounds
        addChild(boundingBox)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "Background.jpg")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Config.GameLayer.Background
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        let center = CGPoint(x: size.width/2, y: size.height/2)
        player = Player(center)
        addChild(player)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(GameScene.panDetected(_:)))
        self.view!.addGestureRecognizer(panGesture)
        
        playBackgroundMusic("BGM.mp3")
        setupHUD()
        spawnWave()
        
        // debug mode
        if Config.Developer.DebugMode {
            debugDrawPlayableArea()
        }
    }
    
    // MARK - Update -
    override func update(_ currentTime: TimeInterval) {
        if !gamePaused {
            if lastUpdateTime > 0 {
                deltaTime = currentTime - lastUpdateTime
            } else {
                deltaTime = 0
            }
            lastUpdateTime = currentTime
            
            enumerateChildNodes(withName: "bouncer", using: { node, stop in
                let bouncer = node as! Bouncer
                self.checkBounds(bouncer)
            })
            
            enumerateChildNodes(withName: "seeker", using: { node, stop in
                let seeker = node as! Seeker
                if let targetLocation = self.player?.position {
                    seeker.seek(self.deltaTime, location: targetLocation)
                }
            })
        }
    }
    
    
    // MARK: - Event Handlers -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 0 {
            let location = touches.first!.location(in: self)
            
            if atPoint(location) == resumeButton {
                resumeButton.fontColor = UIColor.cyan
            }
            
            if !gamePaused {
                player.onTeleport(location)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { 
        for touch: AnyObject in touches {
            if atPoint(touch.location(in: self)) == resumeButton {
                resumeButton.fontColor = UIColor.white
                runUnpauseAction()
            }
        }
    }
    
    func panDetected(_ recognizer: UIPanGestureRecognizer) {
        if !gamePaused {
            if recognizer.state == .changed {
                var touchLocation = recognizer.location(in: recognizer.view)
                touchLocation = self.convertPoint(fromView: touchLocation)
                
                let dy = player.position.y - touchLocation.y
                let dx = player.position.x - touchLocation.x
                player.direction(dx, dy: dy)
                
                // Shoot bullets
                player.onAutoFire()
            }
            if recognizer.state == .ended {
                player.stopAutoFire()
            }
        }
    }
    
    
    // MARK - Collision Detections -
    func didBegin(_ contact: SKPhysicsContact) {
        var firstNode: SKNode?
        var secondNode: SKNode?
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstNode = contact.bodyA.node
            secondNode = contact.bodyB.node
        } else {
            firstNode = contact.bodyB.node
            secondNode = contact.bodyA.node
        }
        
        guard firstNode != nil else {
            return
        }
        guard secondNode != nil else {
            return
        }
        
        // bounds & bullet collision
        if firstNode?.physicsBody?.categoryBitMask == PhysicsCategory.OuterBounds, let bullet = secondNode as? Bullet {
            bullet.onDestroy()
        }
        // enemy & bullet collision
        if let enemy = firstNode as? Enemy, let bullet = secondNode as? Bullet {
            bulletDidCollideWithEnemy(enemy, thisBullet: bullet)
        }
        // enemy & player collision
        else if let enemy = firstNode as? Enemy, let player = secondNode as? Player {
            playerDidCollideWithEnemy(enemy, thisPlayer: player)
        }
        // power & player collision
        else if let player = firstNode as? Player, let power = secondNode as? PowerUp {
            playerDidCollideWithPowerUp(player, thisPower: power)
        }
    }
    
    func bulletDidCollideWithEnemy(_ thisEnemy: Enemy, thisBullet: Bullet) {
        let enemyHp = thisEnemy.hitPoints
        let bulletPower = thisBullet.bulletPower
        
        thisBullet.onHit(enemyHp)
        if thisEnemy.onHit(bulletPower) <= 0 {
            let emitter = thisEnemy.explosion()
            let scoreMarker = thisEnemy.scoreMarker()
            
            run(SKAction.sequence([
                SKAction.group([
                    thisEnemy.scoreSound,
                    SKAction.run() {
                        self.addChild(emitter)
                        self.addChild(scoreMarker)
                        
                        self.score += thisEnemy.scorePoints
                        self.scoreLabel.text = "\(self.score)"
                        
                        if self.numOfEnemies <= 0 {
                            self.wave += 1
                            self.spawnWave()
                        }
                    }
                ]),
                SKAction.wait(forDuration: 0.3),
                SKAction.run() {
                    emitter.removeFromParent()
                    scoreMarker.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                    self.spawnPowerUp(thisEnemy.position)
                }
            ]))
        }
    }
    
    func playerDidCollideWithEnemy(_ thisEnemy: Enemy, thisPlayer: Player) {
        thisEnemy.onDestroy()
        if thisPlayer.onDamaged() {
            let damageOverlay = DamageOverlay(size: self.size, duration: thisPlayer.damageDuration)
            addChild(damageOverlay)
            
            let heart = lives.removeLast()
            heart.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.removeFromParent()
            ]))
        }
        
        if thisPlayer.life <= 0 && !Config.Developer.Endless {
            run(SKAction.sequence([
                SKAction.run() {
                    self.physicsWorld.speed = 0
                    thisPlayer.onDestroy()
                },
                SKAction.wait(forDuration: 3.5),
                SKAction.run {
                    self.gameOver()
                }
            ]))
            return
        }
        
        if numOfEnemies <= 0 {
            wave += 1
            spawnWave()
        }
    }
    
    func playerDidCollideWithPowerUp(_ thisPlayer: Player, thisPower: PowerUp) {
        switch thisPower.powerType {
        case .life:
            if let power = thisPower as? LifeUp {
                power.onPickUp(thisPlayer)
                let heart = SKSpriteNode(imageNamed: "Heart")
                heart.size = CGSize(width: 55, height: 50)
                let xPos = (lives.last?.position.x)! - (25 + heart.size.width)
                let yPos = (lives.last?.position.y)!
                heart.position = CGPoint(x: xPos, y: yPos)
                heart.zPosition = Config.GameLayer.HUD
                heart.alpha = 0
                addChild(heart)
                heart.run(SKAction.fadeAlpha(by: 0.75, duration: 0.2))
            }
            break
        }
    }
    
    func checkBounds(_ enemy: Enemy) {
        if enemy.position < playableRect {
            // if visible on screen
            enemy.physicsBody?.collisionBitMask = PhysicsCategory.PlayBounds
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
    
    func pauseGame() {
        gamePaused = true
        backgroundMusicPlayer.pause()
        
        pauseOverlay.position = CGPoint(x: size.width/2, y: size.height/2)
        pauseOverlay.zPosition = Config.GameLayer.Overlay
        pauseOverlay.fillColor = UIColor.black
        pauseOverlay.alpha = 0.75
        addChild(pauseOverlay)
        
        pauseLabel = SKLabelNode(fontNamed: Config.Font.GameOverFont)
        pauseLabel.position = CGPoint(x: size.width/2, y: size.height/2+250)
        pauseLabel.zPosition = Config.GameLayer.Overlay
        pauseLabel.fontColor = UIColor.cyan
        pauseLabel.fontSize = 200
        pauseLabel.text = "Paused"
        addChild(pauseLabel)
        
        resumeButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        resumeButton.position = CGPoint(x: size.width/2, y: size.height/2-250)
        resumeButton.zPosition = Config.GameLayer.Overlay
        resumeButton.fontSize = 60
        resumeButton.text = "Resume"
        addChild(resumeButton)
    }
    
    func runPauseAction() {
        // pause game
        pauseGame()
        physicsWorld.speed = 0
        self.view?.isPaused = true
    }
    
    func runUnpauseAction() {
        // unpause game
        run(SKAction.sequence([
            SKAction.group([
                SKAction.run() {
                    self.pauseLabel.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                },
                SKAction.run() {
                    self.resumeButton.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.5),
                        SKAction.removeFromParent()
                    ]))
                },
                SKAction.run() {
                    self.pauseOverlay.run(SKAction.sequence([
                        SKAction.fadeOut(withDuration: 1.0),
                        SKAction.removeFromParent()
                    ]))
                }
            ]),
            SKAction.wait(forDuration: 1.0),
            SKAction.run() {
                self.gamePaused = false
                self.physicsWorld.speed = 1
                backgroundMusicPlayer.play()
                self.view?.isPaused = false
            }
        ]))
    }
    
    
    // MARK: - Helper Functions -
    func setupHUD() {
        let scoreTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
        scoreTextLabel.position = CGPoint(x: 50, y: size.height-50)
        scoreTextLabel.zPosition = Config.GameLayer.HUD
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.verticalAlignmentMode = .top
        scoreTextLabel.fontColor = Config.Font.GameUIColor
        scoreTextLabel.fontSize = Config.Font.GameTextSize
        scoreTextLabel.text = "Score"
        addChild(scoreTextLabel)
        
        scoreLabel.position = CGPoint(x: 50, y: size.height-100)
        scoreLabel.zPosition = Config.GameLayer.HUD
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.fontColor = Config.Font.GameUIColor
        scoreLabel.fontSize = Config.Font.GameLabelSize
        scoreLabel.text = "\(score)"
        addChild(scoreLabel)
        
        let waveTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
        waveTextLabel.position = CGPoint(x: size.width/2, y: size.height-50)
        waveTextLabel.zPosition = Config.GameLayer.HUD
        waveTextLabel.horizontalAlignmentMode = .center
        waveTextLabel.verticalAlignmentMode = .top
        waveTextLabel.fontColor = Config.Font.GameUIColor
        waveTextLabel.fontSize = Config.Font.GameTextSize
        waveTextLabel.text = "Wave"
        addChild(waveTextLabel)
        
        waveLabel.position = CGPoint(x: size.width/2, y: size.height-100)
        waveLabel.zPosition = Config.GameLayer.HUD
        waveLabel.horizontalAlignmentMode = .center
        waveLabel.verticalAlignmentMode = .top
        waveLabel.fontColor = Config.Font.GameUIColor
        waveLabel.fontSize = Config.Font.GameLabelSize
        waveLabel.text = "\(wave)"
        addChild(waveLabel)
        
        let lifeTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
        lifeTextLabel.position = CGPoint(x: size.width-50, y: size.height-50)
        lifeTextLabel.zPosition = Config.GameLayer.HUD
        lifeTextLabel.horizontalAlignmentMode = .right
        lifeTextLabel.verticalAlignmentMode = .top
        lifeTextLabel.fontColor = Config.Font.GameUIColor
        lifeTextLabel.fontSize = Config.Font.GameTextSize
        lifeTextLabel.text = "Life"
        addChild(lifeTextLabel)
        
        for i in 1...player.life {
            let heart = SKSpriteNode(imageNamed: "Heart")
            heart.size = CGSize(width: 55, height: 50)
            let xPos = size.width - (25 + heart.size.width) * CGFloat(i)
            let yPos = size.height - (75 + heart.size.height)
            heart.position = CGPoint(x: xPos, y: yPos)
            heart.zPosition = Config.GameLayer.HUD
            heart.alpha = 0.75
            
            let dot = SKShapeNode(circleOfRadius: 5)
            dot.position = CGPoint(x: xPos, y: yPos)
            dot.zPosition = Config.GameLayer.HUD
            dot.fillColor = Config.Font.GameUIColor
            dot.lineWidth = 0
            dot.alpha = 0.25
            
            addChild(dot)
            addChild(heart)
            lives.append(heart)
        }
    }
    
    // Spawn outside playableRect
    func getRandomOutsideSpawnLocation() -> CGPoint {
        var location = CGPoint(
            x: CGFloat.random(spawnZoneBounds.minX, max: spawnZoneBounds.maxX),
            y: CGFloat.random(spawnZoneBounds.minY, max: spawnZoneBounds.maxY)
        )
        
        let zone = Int.random(1...4)
        switch zone {
        case 1: location.y = spawnZoneBounds.maxY   // Top
            break
        case 2: location.x = spawnZoneBounds.minX   // Left
            break
        case 3: location.y = spawnZoneBounds.minY   // Bottom
            break
        case 4: location.x = spawnZoneBounds.maxX   // Right
            break
        default: break
        }
        
        return location
    }
    
    // Spawn inside playableRect
    func getRandomInsideSpawnLocation() -> CGPoint {
        let location = CGPoint(
            x: CGFloat.random(playableRect.minX, max: playableRect.maxX),
            y: CGFloat.random(playableRect.minY, max: playableRect.maxY)
        )
        return location
    }
    
    func gameOver() {
        backgroundMusicPlayer.stop()
        gameManager.loadGameOverScene(score)
    }
    
    
    // MARK: - Spawn Methods -
    func spawnWave() {
        waveLabel.text = "\(wave)"
        
        // http://www.meta-calculator.com/online/9j13df5xtv8b
        var waveEnemyCount = Int(5.5 * sqrt(0.5 * Double(wave)))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run() {
                // Spawn seeker wave once every 3 waves after Wave 5
                if self.wave > 5 && self.wave % 3 == 0 {
                    // Spawn half of enemies as Seekers
                    waveEnemyCount /= 2
                    let circleEnemyCount = self.wave < 16 ? CGFloat(waveEnemyCount) : 16.0
                    //let location = CGPoint(x: self.playableRect.width/2, y: self.playableRect.height/2)
                    let location = self.player.position
                    _ = self.spawnEnemyCircle(EnemyTypes.seeker, count: circleEnemyCount, center: location, radius: 500)
                }
                else if self.wave > 10 && self.wave % 3 == 2 {
                    // Spawn Ninja Stars
                }
                self.spawnEnemy(.bouncer, count: waveEnemyCount)
            }
        ]))
    }
    
    func spawnEnemy(_ type: EnemyTypes, count: Int) {
        for _ in 0..<count {
            let enemy = createEnemy(type, location: getRandomOutsideSpawnLocation(), gameScene: self)
            addChild(enemy)
            enemy.move()
        }
    }
    
    func spawnEnemyCircle(_ type: EnemyTypes, count: CGFloat, center: CGPoint, radius: CGFloat?) -> [Enemy] {
        let r = (radius != nil) ? radius : (100 + 50 * (count - 1))
        var circleEnemies: [Enemy] = []
        
        for i in 0..<Int(count) {
            let angle = CGFloat(i) * 360.0 / count
            let pos = CGPoint(
                x: center.x + cos(angle * degreesToRadians) * r!,
                y: center.y + sin(angle * degreesToRadians) * r!)
            let enemy = createEnemy(type, location: pos, gameScene: self)
            addChild(enemy)
            circleEnemies.append(enemy)
        }
        
        return circleEnemies
    }
    
    func spawnPowerUp(_ location: CGPoint) {
        let type: PowerTypes
        
        let dice = Int.random(1...1000)
        switch dice {
        case 1...50:
            if player.life < player.maxLife {
                type = PowerTypes.life
            } else {
                return
            }
            break
        default:
            return
        }
        
        let powerUp = createPowerUp(type, location: location)
        addChild(powerUp)
        
        let count = CGFloat(powerUp.enemyCount)
        for i in 0..<Int(powerUp.enemyCount) {
            let radius = 100 + 50 * (count - 1)
            let angle = CGFloat(i) * 360.0 / count
            let targetPos = CGPoint(
                x: location.x + cos(angle * degreesToRadians) * radius,
                y: location.y + sin(angle * degreesToRadians) * radius)
            let ninja = NinjaStar(pos: location, toPos: targetPos, gameScene: self)
            addChild(ninja)
            powerUp.ninjas.append(ninja)
        }
    }
    
    
    // MARK: - Debug -
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 10.0
        addChild(shape)
    }
}
