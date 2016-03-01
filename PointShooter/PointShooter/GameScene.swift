//
//  GameScene.swift
//  PointShooter
//
//  Created by Ashton Wai on 2/25/16.
//  Copyright (c) 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var ship:SKSpriteNode!
    var lastTime:CFTimeInterval = 0
    var deltaTime:CFTimeInterval = 0
    var bulletSpeed:Double = 1
    let fireRate:Float = 0.1
    var fireTimer:Float = 0.0
    var autoFiring = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        ship = SKSpriteNode(imageNamed:"Spaceship")
        ship.xScale = 0.25
        ship.yScale = 0.25
        ship.position = CGPointMake(size.width/2, size.height/2)
        self.addChild(ship)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePanFrom:"))
        self.view!.addGestureRecognizer(gestureRecognizer)
        
        fireTimer = fireRate
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
    
    func autoFire() {
        let circle = SKShapeNode.init(circleOfRadius: 10)
        circle.fillColor = SKColor.redColor()
        circle.position = CGPointMake(ship.position.x, ship.position.y)
        let moveAction = SKAction.moveBy(CGVector(dx: cos(ship.zRotation + CGFloat(M_PI/2))*1000, dy: sin(ship.zRotation + CGFloat(M_PI/2))*1000), duration: bulletSpeed)
        let deleteAction = SKAction.removeFromParent()
        let blockAction = SKAction.runBlock({print("Done moving, deleting")})
        circle.runAction(SKAction.sequence([moveAction,blockAction,deleteAction]))
        addChild(circle)
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
}
