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
}

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ship:SKSpriteNode!
    var lastTime:CFTimeInterval = 0
    var deltaTime:CFTimeInterval = 0
    var bulletSpeed:Double = 1
    let fireRate:Float = 0.1
    var fireTimer:Float = 0.0
    var autoFiring = false
    
    let playableRect: CGRect
    
    override init(size: CGSize) {
        // make constant for max aspect ratio support 16:9
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        // calculate playable height
        let playableHeight = size.width / maxAspectRatio
        // center playable rectangle on the screen
        let playableMargin = (size.height - playableHeight) / 2.0
        // make centered rectangle on the screen
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        // call the initializer of the superclass
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        // must also override required NSCoder initializer when override the default initializer
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        ship = SKSpriteNode(imageNamed:"Spaceship")
        ship.xScale = 0.5
        ship.yScale = 0.5
        ship.position = CGPointMake(size.width/2, size.height/2)
        self.addChild(ship)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanFrom:"))
        self.view!.addGestureRecognizer(gestureRecognizer)
        
        fireTimer = fireRate
        
        spawnEnemy()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        deltaTime = currentTime - lastTime
        lastTime = currentTime
        
        if (autoFiring) {
            if (fireTimer > 0) {
                fireTimer -= Float(deltaTime)
            } else {
                autoFire()
                fireTimer = fireRate
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        for touch in touches {
            let location = touch.locationInNode(self)
            ship.position = location
        }
    }
    
    func handlePanFrom(recognizer: UIPanGestureRecognizer) {
        if (recognizer.state == .Changed) {
            var touchLocation = recognizer.locationInView(recognizer.view)
            touchLocation = self.convertPointFromView(touchLocation)
            
            // TODO: Calculate player rotation angle here
            let dy = ship.position.y - touchLocation.y
            let dx = ship.position.x - touchLocation.x
            
            let angle = atan2(dy, dx)
            let action = SKAction.rotateToAngle(angle + CGFloat(M_PI/2), duration: 0.0)
            ship.runAction(action)
            
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
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet != 0)) {
                bulletDidCollideWithEnemy(firstBody.node as! SKShapeNode, enemy: secondBody.node as! SKShapeNode)
        }
    }
    
    func bulletDidCollideWithEnemy(bullet:SKShapeNode, enemy:SKShapeNode) {
        bullet.removeFromParent()
        enemy.removeFromParent()
        
        spawnEnemy()
    }
    
    func autoFire() {
        let circle = SKShapeNode.init(circleOfRadius: 10)
        circle.fillColor = SKColor.redColor()
        circle.position = CGPointMake(ship.position.x, ship.position.y)
        
        circle.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        circle.physicsBody?.dynamic = true
        circle.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        circle.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        circle.physicsBody?.collisionBitMask = PhysicsCategory.None
        circle.physicsBody?.usesPreciseCollisionDetection = true
        
        let moveAction = SKAction.moveBy(CGVector(dx: cos(ship.zRotation + CGFloat(M_PI/2))*2500, dy: sin(ship.zRotation + CGFloat(M_PI/2))*2500), duration: bulletSpeed)
        let deleteAction = SKAction.removeFromParent()
        let blockAction = SKAction.runBlock({print("Done moving, deleting")})
        circle.runAction(SKAction.sequence([moveAction,blockAction,deleteAction]))
        addChild(circle)
    }
    
    func spawnEnemy() {
        let enemy = SKShapeNode(rectOfSize: CGSize(width: 75, height: 75))
        enemy.fillColor = UIColor.greenColor()
        
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 75, height: 75))
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        enemy.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect),
                max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect),
                max: CGRectGetMaxY(playableRect)))
        addChild(enemy)
    }
}
