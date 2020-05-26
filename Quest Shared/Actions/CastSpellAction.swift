//
//  CastSpellAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 14/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class CastSpellAction: Action {
    private let spell: Spell
    
//    override var message: String { return "\(self.actor.name) casts \(spell.name) on \((self.spell as! SingleTargetDamageSpell).targetActor.name)" }
    
    init(actor: Actor, spell: Spell) {
        self.spell = spell

        super.init(actor: actor)
    }
    
    override func perform(state: GameState) {
        self.actor.energy.drain()

        switch self.spell {
        case let singleTargetDamageSpell as SingleTargetDamageSpell:            
            let damage = singleTargetDamageSpell.getDamage()
            singleTargetDamageSpell.targetActor.reduceHealth(with: damage)
            print("\t\(spell.name) hits \(singleTargetDamageSpell.targetActor.name) for \(damage) damage")
            break
        default:
            break
        }
    }
}
