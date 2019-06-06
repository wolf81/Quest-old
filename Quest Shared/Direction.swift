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
    
    var coord: int2 {
        switch self {
        case .up: return int2(0, 1)
        case .down: return int2(0, -1)
        case .left: return int2(-1, 0)
        case .right: return int2(1, 0)
        }
    }
}
