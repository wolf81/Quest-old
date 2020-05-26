//
//  DungeonLayout.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum DungeonLayout: String {
    case square
    case rectangle
    case box
    case cross
    case dagger
    case saltire
    case keep
    case hexagon
    case round
    
    var aspectRatio: Float {
        switch self {
        case .square: return 1
        case .rectangle: return 1.3
        case .box: return 1
        case .cross: return 1
        case .dagger: return 1.3
        case .saltire: return 1
        case .keep: return 1
        case .hexagon: return 0.9
        case .round: return 1
        }
    }
    
    var mask: Mask? {
        switch self {
        case .box:
            return [
                [1, 1, 1],
                [1, 0, 1],
                [1, 1, 1],
            ]
        case .dagger:
            return [
                [0, 1, 0],
                [1, 1, 1],
                [0, 1, 0],
                [0, 1, 0],
            ]
        case .keep:
            return [
                [1, 1, 0, 0, 1, 1],
                [1, 1, 1, 1, 1, 1],
                [0, 1, 1, 1, 1, 0],
                [0, 1, 1, 1, 1, 0],
                [1, 1, 1, 1, 1, 1],
                [1, 1, 0, 0, 1, 1],
            ]
        default:
            return nil
        }
    }
}
