//
//  RoomSize.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum RoomSize: String {
    case small
    case medium
    case large
    case huge
    case gargantuan
    case colossal
    
    var radix: Int {
        switch self {
        case .small: return 2
        case .medium: return 5
        case .large: return 2
        case .huge: return 5
        case .gargantuan: return 5
        case .colossal: return 8
        }
    }
    
    var size: Int {
        switch self {
        case .small: fallthrough
        case .medium: return 2
        case .large: fallthrough
        case .huge: return 5
        case .gargantuan: fallthrough
        case .colossal: return 8
        }
    }
    
    var isHuge: Bool {
        return [.huge, .gargantuan, .colossal].contains(self)
    }
}
