//
//  CorridorLayout.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum CorridorLayout {
    case labyrinth
    case errant
    case straight
    
    var straightPercent: Int {
        switch self {
        case .labyrinth: return 0
        case .errant: return 50
        case .straight: return 90
        }
    }
    
    var closeArcs: Bool {
        return self == .straight || self == .errant
    }
}
