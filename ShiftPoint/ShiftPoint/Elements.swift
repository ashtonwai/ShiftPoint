//
//  Elements.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 9/1/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

// MARK: - HUD Elements -
func elScoreTextLabel(_ position: CGPoint) -> SKLabelNode {
    let scoreTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    scoreTextLabel.position = position
    scoreTextLabel.zPosition = Config.GameLayer.HUD
    scoreTextLabel.horizontalAlignmentMode = .left
    scoreTextLabel.verticalAlignmentMode = .top
    scoreTextLabel.fontColor = Config.Font.GameUIColor
    scoreTextLabel.fontSize = Config.Font.GameTextSize
    scoreTextLabel.text = "Score"
    return scoreTextLabel
}

func elScoreLabel(_ position: CGPoint, score: Int) -> SKLabelNode {
    let scoreLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    scoreLabel.position = position
    scoreLabel.zPosition = Config.GameLayer.HUD
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.verticalAlignmentMode = .top
    scoreLabel.fontColor = Config.Font.GameUIColor
    scoreLabel.fontSize = Config.Font.GameLabelSize
    scoreLabel.text = "\(score)"
    return scoreLabel
}

func elWaveTextLabel(_ position: CGPoint) -> SKLabelNode {
    let waveTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    waveTextLabel.position = position
    waveTextLabel.zPosition = Config.GameLayer.HUD
    waveTextLabel.horizontalAlignmentMode = .center
    waveTextLabel.verticalAlignmentMode = .top
    waveTextLabel.fontColor = Config.Font.GameUIColor
    waveTextLabel.fontSize = Config.Font.GameTextSize
    waveTextLabel.text = "Wave"
    return waveTextLabel
}

func elWaveLabel(_ position: CGPoint, wave: Int) -> SKLabelNode {
    let waveLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    waveLabel.position = position
    waveLabel.zPosition = Config.GameLayer.HUD
    waveLabel.horizontalAlignmentMode = .center
    waveLabel.verticalAlignmentMode = .top
    waveLabel.fontColor = Config.Font.GameUIColor
    waveLabel.fontSize = Config.Font.GameLabelSize
    waveLabel.text = "\(wave)"
    return waveLabel
}

func elLifeTextLabel(_ position: CGPoint) -> SKLabelNode {
    let lifeTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    lifeTextLabel.position = position
    lifeTextLabel.zPosition = Config.GameLayer.HUD
    lifeTextLabel.horizontalAlignmentMode = .right
    lifeTextLabel.verticalAlignmentMode = .top
    lifeTextLabel.fontColor = Config.Font.GameUIColor
    lifeTextLabel.fontSize = Config.Font.GameTextSize
    lifeTextLabel.text = "Life"
    return lifeTextLabel
}

func elHeart() -> SKSpriteNode {
    let heart = SKSpriteNode(imageNamed: "Heart")
    heart.size = CGSize(width: 55, height: 50)
    heart.zPosition = Config.GameLayer.HUD
    heart.alpha = 0.75
    return heart
}

func elHeartDot(_ position: CGPoint) -> SKShapeNode {
    let dot = SKShapeNode(circleOfRadius: 5)
    dot.position = position
    dot.zPosition = Config.GameLayer.HUD
    dot.fillColor = Config.Font.GameUIColor
    dot.lineWidth = 0
    dot.alpha = 0.25
    return dot
}
