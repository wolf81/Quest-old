//
//  Spell.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 14/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

protocol Spell {
    var name: String { get }
    
    var level: Int { get }
    
    var manaCost: Int { get }
    
    var difficultyClass: Int { get }

    var actor: Actor { get }
}

extension Spell {
    var manaCost: Int { self.level * 2 + 1 }
    
    var difficultyClass: Int { return 10 + self.actor.level + self.actor.attributes.mind.bonus }
}

protocol SingleTargetDamageSpell: Spell {
    var targetActor: Actor { get }
    
    func getDamage() -> Int
    
    init(actor: Actor, targetActor: Actor)
}

class MagicMissile: SingleTargetDamageSpell {
    var name: String { return "Magic Missile" }
    
    var level: Int { return 1 }
    
    let actor: Actor
    
    let targetActor: Actor
    
    required init(actor: Actor, targetActor: Actor) {
        self.actor = actor
        self.targetActor = targetActor
    }
    
    func getDamage() -> Int {
        let missileCount = min(self.actor.level + 1 / 2, 5)
        
        var damage: Int = 0
        
        for _ in (1 ..< missileCount) {
            damage += HitDie.d4(1, 1).randomValue
        }
        
        return damage
    }
}
