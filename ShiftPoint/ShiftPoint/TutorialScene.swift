//
//  TutorialScene.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 5/16/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class TutorialScene : SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    let userDefaults = UserDefaults.standard
    var gameManager: GameManager?
    var playableRect: CGRect = CGRect.zero
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
    
    override func didMove(to view: SKView) {
        let maxAspectRatio: CGFloat = 4.0 / 3.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height - maxAspectRatioHeight) / 2
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: size.height-playableMargin*2)
        
        instruction.position = CGPoint(x: size.width/2, y: size.height-100)
        instruction.zPosition = Config.GameLayer.HUD
        instruction.horizontalAlignmentMode = .center
        instruction.verticalAlignmentMode = .center
        instruction.fontColor = Config.Font.GameUIColor
        instruction.fontSize = Config.Font.GameTextSize
        addChild(instruction)
        
        skipButton.position = CGPoint(x: size.width-50, y: 50)
        skipButton.zPosition = Config.GameLayer.HUD
        skipButton.horizontalAlignmentMode = .right
        skipButton.verticalAlignmentMode = .bottom
        skipButton.fontColor = Config.Font.GameUIColor
        skipButton.fontSize = 80
        skipButton.text = "Skip"
        addChild(skipButton)
        
        setupWorld()
    }
    
    
    // MARK: - Event Handlers -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 0 {
            let location = touches.first!.location(in: self)
            
            player.onTeleport(location)
            
            if atPoint(location) == skipButton {
                skipButton.fontColor = SKColor.cyan
                gameManager?.loadGameScene()
            }
            
            if atPoint(location) == targetCircle {
                if currentPoint < 3 {
                    currentPoint += 1
                    teleportTarget(targetPoints[currentPoint])
                } else {
                    targetCircle.removeAllActions()
                    targetCircle.removeFromParent()
                    shootingTutorial()
                }
            }
            
            if atPoint(location) == shootPos {
                shootPos?.removeAllActions()
                shootPos?.removeFromParent()
                
                arrow?.position = CGPoint(x: size.width/2, y: size.height/2)
                arrow?.zPosition = Config.GameLayer.Sprite
                arrow?.xScale = 0.25
                arrow?.yScale = 0.25
                addChild(arrow!)
                
                arrow?.run(SKAction.repeatForever(SKAction.sequence([
                    SKAction.group([
                        SKAction.moveTo(y: size.height-300, duration: 1.0),
                        SKAction.fadeOut(withDuration: 1.0)
                    ]),
                    SKAction.wait(forDuration: 0.25),
                    SKAction.group([
                        SKAction.moveTo(y: size.height/2, duration: 0),
                        SKAction.fadeAlpha(to: 0.75, duration: 0)
                    ])
                ])))
            }
        }
    }
    
    func panDetected(_ recognizer: UIPanGestureRecognizer) {
        if  recognizer.state == .began {
            if arrow != nil {
                arrow?.removeAllActions()
                arrow?.removeFromParent()
            }
        }
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
            
            run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.run() {
                    self.completeTutorial()
                }
            ]))
        }
    }
    
    
    // MARK: - Helper Functions -
    func setupWorld() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "Background.jpg")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Config.GameLayer.Background
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        player.position = CGPoint(x: size.width/2, y: size.height/2)
        player.zPosition = Config.GameLayer.Sprite
        addChild(player)
        
        instruction.text = "Tab to teleport to the location"
        
        targetCircle.position = targetPoints[currentPoint]
        targetCircle.zPosition = Config.GameLayer.Sprite
        targetCircle.fillColor = SKColor.clear
        targetCircle.strokeColor = SKColor.cyan
        targetCircle.lineWidth = 7
        addChild(targetCircle)
        
        targetCircle.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.scale(by: 2, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0),
            ]),
            SKAction.wait(forDuration: 0.25),
            SKAction.group([
                SKAction.scale(to: 1, duration: 0),
                SKAction.fadeAlpha(to: 0.75, duration: 0)
            ])
        ])))
        
        teleportTarget(targetPoints[currentPoint])
    }
    
    func teleportTarget(_ targetPoint: CGPoint) {
        targetCircle.position = targetPoints[currentPoint]
    }
    
    func shootingTutorial() {
        shootPos?.position = CGPoint(x: size.width/2, y: size.height/2)
        shootPos?.zPosition = Config.GameLayer.Sprite
        shootPos?.fillColor = SKColor.clear
        shootPos?.strokeColor = SKColor.cyan
        shootPos?.lineWidth = 7
        addChild(shootPos!)
        
        shootPos?.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 0.5, duration: 1.0),
                SKAction.fadeOut(withDuration: 1.0)
            ]),
            SKAction.wait(forDuration: 0.25),
            SKAction.group([
                SKAction.scale(to: 1, duration: 0),
                SKAction.fadeAlpha(by: 0.75, duration: 0)
            ])
        ])))
        
        instruction.text = "Hold and drag from the target location"
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panDetected(_:)))
        self.view!.addGestureRecognizer(panRecognizer)
    }
    
    func completeTutorial() {
        userDefaults.set(true, forKey: "skipTutorial")
        
        let overlay = SKShapeNode(rectOf: size)
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.zPosition = Config.GameLayer.Overlay
        overlay.fillColor = UIColor.black
        overlay.alpha = 0.75
        addChild(overlay)
        
        let completeLabel = SKLabelNode(fontNamed: Config.Font.GameOverFont)
        completeLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        completeLabel.zPosition = Config.GameLayer.Overlay
        completeLabel.fontColor = SKColor.green
        completeLabel.fontSize = 120
        completeLabel.text = "You Are Ready To Shift!"
        addChild(completeLabel)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run() {
                self.gameManager?.loadGameScene()
            }
        ]))
    }
}
