//
//  Constants.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 14/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import CoreGraphics
import Foundation

struct Constants {
    static let energyPerTick: Int = 10

    static let minimumEnergyCost: Int = 10
    
    static let rangedWeaponMeleePenalty = -2
    
    static let tileSize: CGSize = CGSize(width: 48, height: 48)
    
    struct AnimationDuration {
        static let `default`: TimeInterval = 2.0
    }
}
