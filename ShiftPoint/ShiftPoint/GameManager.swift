//
//  GameManager.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 5/3/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation

protocol GameManager {
    func loadTutorialScene()
    func loadGameScene()
    func loadGameOverScene(_ score: Int)
}
