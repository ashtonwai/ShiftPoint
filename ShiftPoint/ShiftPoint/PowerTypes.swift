//
//  PowerTypes.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 8/31/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

enum PowerTypes {
    case Life
}

func createPowerUp(powerType: PowerTypes, location: CGPoint) -> PowerUp {
    var power: PowerUp
    
    switch powerType {
    case .Life:
        power = LifeUp(pos: location)
        break
    }
    
    return power
}