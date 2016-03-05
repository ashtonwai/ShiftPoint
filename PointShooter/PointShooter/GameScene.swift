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
    var player: Player!
    
    var lastUpdateTime: CFTimeInterval = 0
    var deltaTime: CFTimeInterval = 0
    
    var bulletSpeed: Double = 1
    let fireRate: Float = 0.1
    var fireTimer: Float = 0.0
    var autoFiring = false
    
    var top:CGFloat = 0, bottom:CGFloat = 0, left:CGFloat = 0, right:CGFloat = 0
    let playableRect: CGRect
    
    let numOfEnemies = 20
    
    override init(size: CGSize) {
        // make constant for max aspect ratio support 4:3
        let maxAspectRatio: CGFloat = 4.0 / 3.0
        // calculate playable height
        let playableHeight = size.width / maxAspectRatio
        // center playable rectangle on the screen
        let playableMargin = (size.height - playableHeight) / 2.0
        // make centered rectangle on the screen
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        player = Player(xScale: 0.15, yScale: 0.15)
        player.name = "player"
        player.position = CGPointMake(size.width/2, size.height/2)
        addChild(player)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panDetected:"))
        self.view!.addGestureRecognizer(gestureRecognizer)
        
        fireTimer = fireRate
        
        for _ in 0...numOfEnemies-1 {
            spawnEnemy()
        }
        
        // debug functions
        debugDrawPlayableArea()
    }
    
    override func update(currentTime: CFTimeInterval) {
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if (autoFiring) {
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
            
            /*if (enemy.position > self.playableRect) {
                print("outside")
            } else {
                print("inside")
            }*/
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            player.position = location
        }
    }
    
    func panDetected(recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .Changed) {
            var touchLocation = recognizer.locationInView(recognizer.view)
            touchLocation = self.convertPointFromView(touchLocation)
            
            let dy = player.position.y - touchLocation.y
            let dx = player.position.x - touchLocation.x
            player.direction(dx, dy: dy)
            
            autoFiring = true
        }
        if (recognizer.state == .Ended) {
            autoFiring = false
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
                bulletDidCollideWithEnemy(firstBody.node as! SKShapeNode, enemy: secondBody.node as! SKShapeNode)
        }
        
        // player & enemy collison
        if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Enemy != 0)) {
               playerDidCollideWithEnemy(firstBody.node as! SKShapeNode, player: secondBody.node as! SKSpriteNode)
        }
    }
    
    func bulletDidCollideWithEnemy(bullet: SKShapeNode, enemy: SKShapeNode) {
        bullet.removeFromParent()
        enemy.removeFromParent()
        spawnEnemy()
    }
    
    func playerDidCollideWithEnemy(enemy: SKShapeNode, player: SKSpriteNode) {
        enemy.removeFromParent()
        // decrease health
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
    }
    
    func autoFire() {
        let bullet = Bullet(circleOfRadius: 10)
        bullet.position = CGPointMake(player.position.x, player.position.y)
        addChild(bullet)
        
        let dx = cos(player.zRotation + CGFloat(M_PI/2)) * 2500
        let dy = sin(player.zRotation + CGFloat(M_PI/2)) * 2500
        bullet.move(dx, dy: dy)
    }
    
    func spawnEnemy() {
        let enemy = Enemy(rectOfSize: CGSize(width: 75, height: 75))
        enemy.name = "enemy"
        enemy.position = randomCGPointInRect(playableRect, margin: 150)
        enemy.forward = CGPoint.randomUnitVector()
        addChild(enemy)
    }
}
