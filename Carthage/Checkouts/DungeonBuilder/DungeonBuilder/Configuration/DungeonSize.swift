//
//  DungeonSize.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum DungeonSize: String {
    case fine // = 11
    case diminutive // = 14
    case tiny // = 17
    case small // = 22
    case medium // = 28
    case large // = 35
    case huge // = 44
    case gargantuan // = 56
    case colossal // = 70
    
    var size: Int {
        switch self {
        case .fine: return 11
        case .diminutive: return 14
        case .tiny: return 17
        case .small: return 22
        case .medium: return 28
        case .large: return 35
        case .huge: return 44
        case .gargantuan: return 56
        case .colossal: return 70
        }
    }
}
