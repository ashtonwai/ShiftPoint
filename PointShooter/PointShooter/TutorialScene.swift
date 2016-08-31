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
    var skipButton: SKLabelNode
    
    var targetPoint1: CGPoint
    var targetPoint2: CGPoint
    var targetPoint3: CGPoint
    var targetPoint4: CGPoint
    var targetPoints: [CGPoint]
    var currentPoint: Int = 0
    var shootPos: SKShapeNode?
    var arrow: SKSpriteNode?
    
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode: SKSceneScaleMode, gameManager: GameManager) {
        self.targetPoint1 = CGPoint(x: size.width-500, y: size.height-300)
        self.targetPoint2 = CGPoint(x: 500, y: size.height-300)
        self.targetPoint3 = CGPoint(x: 500, y: 300)
        self.targetPoint4 = CGPoint(x: size.width-500, y: 300)
        self.targetPoints = [targetPoint1, targetPoint2, targetPoint3, targetPoint4]
        self.targetCircle = SKShapeNode(circleOfRadius: 70)
        self.instruction = SKLabelNode(fontNamed: Config.Font.MainFont)
        self.skipButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        self.shootPos = SKShapeNode(circleOfRadius: 100)
        self.arrow = SKSpriteNode(imageNamed: "Arrow")
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
        
        skipButton.position = CGPointMake(size.width-50, 50)
        skipButton.zPosition = Config.GameLayer.HUD
        skipButton.horizontalAlignmentMode = .Right
        skipButton.verticalAlignmentMode = .Bottom
        skipButton.fontColor = Config.Font.GameUIColor
        skipButton.fontSize = 80
        skipButton.text = "Skip"
        addChild(skipButton)
        
        setupWorld()
    }
    
    
    // MARK: - Event Handlers -
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            player.onTeleport(location)
            
            if nodeAtPoint(touch.locationInNode(self)) == skipButton {
                skipButton.fontColor = SKColor.cyanColor()
                gameManager?.loadGameScene()
            }
            
            if nodeAtPoint(touch.locationInNode(self)) == targetCircle {
                if currentPoint < 3 {
                    currentPoint += 1
                    teleportTarget(targetPoints[currentPoint])
                } else {
                    targetCircle.removeAllActions()
                    targetCircle.removeFromParent()
                    shootingTutorial()
                }
            }
            
            if nodeAtPoint(touch.locationInNode(self)) == shootPos {
                shootPos?.removeAllActions()
                shootPos?.removeFromParent()
                
                arrow?.position = CGPoint(x: size.width/2, y: size.height/2)
                arrow?.zPosition = Config.GameLayer.Sprite
                arrow?.xScale = 0.25
                arrow?.yScale = 0.25
                addChild(arrow!)
                
                arrow?.runAction(SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.group([
                        SKAction.moveToY(size.height-300, duration: 1.0),
                        SKAction.fadeOutWithDuration(1.0)
                    ]),
                    SKAction.waitForDuration(0.25),
                    SKAction.group([
                        SKAction.moveToY(size.height/2, duration: 0),
                        SKAction.fadeAlphaTo(0.75, duration: 0)
                    ])
                ])))
            }
        }
    }
    
    func panDetected(recognizer: UIPanGestureRecognizer) {
        if  recognizer.state == .Began {
            if arrow != nil {
                arrow?.removeAllActions()
                arrow?.removeFromParent()
            }
        }
        if recognizer.state == .Changed {
            var touchLocation = recognizer.locationInView(recognizer.view)
            touchLocation = self.convertPointFromView(touchLocation)
            
            let dy = player.position.y - touchLocation.y
            let dx = player.position.x - touchLocation.x
            player.direction(dx, dy: dy)
            
            // Shoot bullets
            player.onAutoFire()
        }
        if recognizer.state == .Ended {
            player.stopAutoFire()
            
            runAction(SKAction.sequence([
                SKAction.waitForDuration(1.0),
                SKAction.runBlock() {
                    self.completeTutorial()
                }
            ]))
        }
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
    
    func shootingTutorial() {
        shootPos?.position = CGPointMake(size.width/2, size.height/2)
        shootPos?.zPosition = Config.GameLayer.Sprite
        shootPos?.fillColor = SKColor.clearColor()
        shootPos?.strokeColor = SKColor.cyanColor()
        shootPos?.lineWidth = 7
        addChild(shootPos!)
        
        shootPos?.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.group([
                SKAction.scaleTo(0.5, duration: 1.0),
                SKAction.fadeOutWithDuration(1.0)
            ]),
            SKAction.waitForDuration(0.25),
            SKAction.group([
                SKAction.scaleTo(1, duration: 0),
                SKAction.fadeAlphaBy(0.75, duration: 0)
            ])
        ])))
        
        instruction.text = "Hold and drag from the target location"
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDetected(_:)))
        self.view!.addGestureRecognizer(panRecognizer)
    }
    
    func completeTutorial() {
        userDefaults.setBool(true, forKey: "skipTutorial")
        
        let overlay = SKShapeNode(rectOfSize: size)
        overlay.position = CGPointMake(size.width/2, size.height/2)
        overlay.zPosition = Config.GameLayer.Overlay
        overlay.fillColor = UIColor.blackColor()
        overlay.alpha = 0.75
        addChild(overlay)
        
        let completeLabel = SKLabelNode(fontNamed: Config.Font.GameOverFont)
        completeLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        completeLabel.zPosition = Config.GameLayer.Overlay
        completeLabel.fontColor = SKColor.greenColor()
        completeLabel.fontSize = 120
        completeLabel.text = "You Are Ready To Shift!"
        addChild(completeLabel)
        
        runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                self.gameManager?.loadGameScene()
            }
        ]))
    }
}
