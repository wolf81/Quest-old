//
//  Effect.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

enum EffectType: String {
    case reduceDamage
    case restoreHealth
    case lowerMovementEnergyCost
    case raiseMovementEnergyCost
    case limitSight
    case search
    case stealth
}

class Effect: Entity {
    var type: EffectType
    
    var value: Int
        
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        let typeName = json["type"] as! String
        self.type = EffectType(rawValue: typeName)!
        self.value = json["value"] as! Int
        
        super.init(json: json, entityFactory: entityFactory, coord: coord)
    }
    
    required init(json: [String : Any]) {
        fatalError()
    }

    func apply(actor: Actor, userInfo: [String: Any]) {
        switch self.type {
        case .restoreHealth:
            actor.hitPoints.restore(hitPoints: self.value)
        default:
            fatalError()
        }
    }    
}
