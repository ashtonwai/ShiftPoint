//
//  TutorialScene.swift
//  PointShooter
//
//  Created by Ashton Wai on 5/16/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class TutorialScene : SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var gameManager: GameManager?
    var playableRect: CGRect = CGRectZero
    var player: Player
    var targetCircle: SKShapeNode
    var instruction: SKLabelNode
    
    var targetPoint1: CGPoint
    var targetPoint2: CGPoint
    var targetPoint3: CGPoint
    var targetPoint4: CGPoint
    var targetPoints: [CGPoint]
    var currentPoint: Int = 0
    
    init(size: CGSize, scaleMode: SKSceneScaleMode, gameManager: GameManager) {
        self.targetPoint1 = CGPoint(x: size.width-500, y: size.height-300)
        self.targetPoint2 = CGPoint(x: 500, y: size.height-300)
        self.targetPoint3 = CGPoint(x: 500, y: 300)
        self.targetPoint4 = CGPoint(x: size.width-500, y: 300)
        self.targetPoints = [targetPoint1, targetPoint2, targetPoint3, targetPoint4]
        self.targetCircle = SKShapeNode(circleOfRadius: 70)
        self.instruction = SKLabelNode(fontNamed: Config.Font.MainFont)
        self.player = Player()
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        let maxAspectRatio: CGFloat = 4.0 / 3.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height-playableMargin*2)
        
        instruction.position = CGPointMake(size.width/2, size.height-100)
        instruction.zPosition = Config.GameLayer.HUD
        instruction.horizontalAlignmentMode = .Center
        instruction.verticalAlignmentMode = .Center
        instruction.fontColor = Config.Font.GameUIColor
        instruction.fontSize = Config.Font.GameTextSize
        addChild(instruction)
        
        setupWorld()
    }
    
    func setupWorld() {
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "Background.jpg")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Config.GameLayer.Background
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        player.position = CGPointMake(size.width/2, size.height/2)
        player.zPosition = Config.GameLayer.Sprite
        addChild(player)
        
        instruction.text = "Tab to teleport to the location"
        
        targetCircle.position = targetPoints[currentPoint]
        targetCircle.zPosition = Config.GameLayer.Sprite
        targetCircle.fillColor = SKColor.clearColor()
        targetCircle.strokeColor = SKColor.cyanColor()
        targetCircle.lineWidth = 7
        addChild(targetCircle)
        
        targetCircle.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.group([
                SKAction.scaleBy(2, duration: 1.0),
                SKAction.fadeOutWithDuration(1.0),
            ]),
            SKAction.waitForDuration(0.25),
            SKAction.group([
                SKAction.scaleTo(1, duration: 0),
                SKAction.fadeAlphaTo(0.75, duration: 0)
            ])
        ])))
        
        teleportTarget(targetPoints[currentPoint])
    }
    
    func teleportTarget(targetPoint: CGPoint) {
        targetCircle.position = targetPoints[currentPoint]
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
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
            
            self.runAction(teleport)
            
            if nodeAtPoint(touch.locationInNode(self)) == targetCircle {
                if currentPoint < 3 {
                    currentPoint += 1
                    teleportTarget(targetPoints[currentPoint])
                } else {
                    targetCircle.removeAllActions()
                    targetCircle.removeFromParent()
                }
            }
        }
    }
}
