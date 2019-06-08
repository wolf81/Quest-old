//
//  Action.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum Action : CustomStringConvertible {
    case move(int2)
    case attack(Creature)
    
    var description: String {
        switch self {
        case .attack(let creature): return "attack \(creature.name)"
        case .move(let coord): return "move to \(coord.x).\(coord.y)"
        }
    }
}
