//
//  Ring.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class Ring: Entity & Equippable {
    var equipmentSlot: EquipmentSlot { .ring }
    
    let effects: [Effect]
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        var effects: [Effect] = []
        if let effectNames = json["effects"] as? [String] {
            for effectName in effectNames {
                let effect = try! entityFactory.newEntity(type: Effect.self, name: effectName)
                effects.append(effect)
            }
        }
        self.effects = effects
        
        super.init(json: json, entityFactory: entityFactory)
    }
    
    static var none: Ring {
        get {
            return self.init(json: [:], entityFactory: EntityFactory())
        }
    }
}
