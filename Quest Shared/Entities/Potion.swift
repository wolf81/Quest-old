//
//  Potion.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 15/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

/*
 
 
 {
    "name": "Heal",
    "effects": ["heal"]
 

    "name": "Fireball"
    "effects": ["damage"]
 }
 
 
 heal1:
 {
    "restore": 6,
 }
 
 
 */

protocol Usable {
    var effects: [Effect] { get }
    
    func use(actor: Actor) 
}

class Potion: Entity & Usable & Lootable {
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
    
    func use(actor: Actor) {
        for effect in self.effects {
            effect.apply(actor: actor, userInfo: [:])
        }
    }
}
