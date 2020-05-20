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
    
    init(actor: Actor, spell: Spell, timeUnitCost: Int) {
        self.spell = spell

        super.init(actor: actor, timeUnitCost: timeUnitCost)
    }
    
    override func perform(game: Game) {
        defer {
            self.actor.subtractTimeUnits(self.timeUnitCost)
        }

        switch self.spell {
        case let singleTargetDamageSpell as SingleTargetDamageSpell:            
            let damage = singleTargetDamageSpell.getDamage()
            singleTargetDamageSpell.targetActor.hitPoints.remove(hitPoints: damage)
            print("\t\(spell.name) hits \(singleTargetDamageSpell.targetActor.name) for \(damage) damage")
            break
        default:
            break
        }
    }
}
