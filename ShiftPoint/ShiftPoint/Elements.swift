//
//  Elements.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 9/1/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

// MARK: - HUD Elements -
func elScoreTextLabel(position: CGPoint) -> SKLabelNode {
    let scoreTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    scoreTextLabel.position = position
    scoreTextLabel.zPosition = Config.GameLayer.HUD
    scoreTextLabel.horizontalAlignmentMode = .Left
    scoreTextLabel.verticalAlignmentMode = .Top
    scoreTextLabel.fontColor = Config.Font.GameUIColor
    scoreTextLabel.fontSize = Config.Font.GameTextSize
    scoreTextLabel.text = "Score"
    return scoreTextLabel
}

func elScoreLabel(position: CGPoint, score: Int) -> SKLabelNode {
    let scoreLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    scoreLabel.position = position
    scoreLabel.zPosition = Config.GameLayer.HUD
    scoreLabel.horizontalAlignmentMode = .Left
    scoreLabel.verticalAlignmentMode = .Top
    scoreLabel.fontColor = Config.Font.GameUIColor
    scoreLabel.fontSize = Config.Font.GameLabelSize
    scoreLabel.text = "\(score)"
    return scoreLabel
}

func elWaveTextLabel(position: CGPoint) -> SKLabelNode {
    let waveTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    waveTextLabel.position = position
    waveTextLabel.zPosition = Config.GameLayer.HUD
    waveTextLabel.horizontalAlignmentMode = .Center
    waveTextLabel.verticalAlignmentMode = .Top
    waveTextLabel.fontColor = Config.Font.GameUIColor
    waveTextLabel.fontSize = Config.Font.GameTextSize
    waveTextLabel.text = "Wave"
    return waveTextLabel
}

func elWaveLabel(position: CGPoint, wave: Int) -> SKLabelNode {
    let waveLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    waveLabel.position = position
    waveLabel.zPosition = Config.GameLayer.HUD
    waveLabel.horizontalAlignmentMode = .Center
    waveLabel.verticalAlignmentMode = .Top
    waveLabel.fontColor = Config.Font.GameUIColor
    waveLabel.fontSize = Config.Font.GameLabelSize
    waveLabel.text = "\(wave)"
    return waveLabel
}

func elLifeTextLabel(position: CGPoint) -> SKLabelNode {
    let lifeTextLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
    lifeTextLabel.position = position
    lifeTextLabel.zPosition = Config.GameLayer.HUD
    lifeTextLabel.horizontalAlignmentMode = .Right
    lifeTextLabel.verticalAlignmentMode = .Top
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

func elHeartDot(position: CGPoint) -> SKShapeNode {
    let dot = SKShapeNode(circleOfRadius: 5)
    dot.position = position
    dot.zPosition = Config.GameLayer.HUD
    dot.fillColor = Config.Font.GameUIColor
    dot.lineWidth = 0
    dot.alpha = 0.25
    return dot
}
