//
//  Direction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum Direction {
    case up
    case down
    case left
    case right
    
    /// A direction is based on an x-value and y-value, e.g. up has an x-value of 0 and y-value of 1, down has an x-value of 0 and y-value of -1, etc...
    var coord: vector_int2 {
        switch self {
        case .up: return vector_int2(0, 1)
        case .down: return vector_int2(0, -1)
        case .left: return vector_int2(-1, 0)
        case .right: return vector_int2(1, 0)
        }
    }
}
