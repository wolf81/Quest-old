//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum Attribute {
    case strength(Int)
    case dexterity(Int)
    case mind(Int)
    
    var bonus: Int {
        switch self {
        case .dexterity(let value): return (value - 10) / 2
        case .mind(let value): return (value - 10) / 2
        case .strength(let value): return (value - 10) / 2
        }
    }
}

class Hero: Actor {
    var attributes: [Attribute]

    init(json: [String : Any], attributes: [Attribute]) {
        self.attributes = attributes
        
        super.init(json: json)

        sprite.zPosition = 1000
    }

    required init(json: [String : Any]) {
        self.attributes = []
        
        super.init(json: json)
    
        sprite.zPosition = 1000
    }
}
