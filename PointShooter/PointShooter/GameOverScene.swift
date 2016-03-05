//
//  GameOverScene.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/5/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene : SKScene {
    let won: Bool
    
    init(size: CGSize, won: Bool) {
        self.won = won
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        if (won) {
            
        } else {
            
        }
    }
}