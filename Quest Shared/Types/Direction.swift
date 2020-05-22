//
//  Direction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum Direction {
    case north
    case south
    case west
    case east
    case northWest
    case northEast
    case southWest
    case southEast

    /// A direction is based on an x-value and y-value, e.g. up has an x-value of 0 and y-value of 1, down has an x-value of 0 and y-value of -1, etc...
    var coord: vector_int2 {
        switch self {
        case .north: return vector_int2(0, 1)
        case .south: return vector_int2(0, -1)
        case .west: return vector_int2(-1, 0)
        case .east: return vector_int2(1, 0)
        case .northWest: return vector_int2(-1, 1)
        case .northEast: return vector_int2(1, 1)
        case .southWest: return vector_int2(-1, -1)
        case .southEast: return vector_int2(1, -1)
        }
    }
}
