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
    
    var coord: SIMD2<Int32> {
        switch self {
        case .up: return SIMD2<Int32>(0, 1)
        case .down: return SIMD2<Int32>(0, -1)
        case .left: return SIMD2<Int32>(-1, 0)
        case .right: return SIMD2<Int32>(1, 0)
        }
    }
}
