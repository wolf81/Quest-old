//
//  AttackAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class MeleeAttackAction: Action {
    public let targetActor: Actor
    
    init(actor: Actor, targetActor: Actor) {
        self.targetActor = targetActor
        super.init(actor: actor)
    }
    
    override var message: String {
        return "[\(self.actor.name)] ✕ \(self.targetActor.name) (\(self.targetActor.hitPoints.current)/\(self.targetActor.hitPoints.base))"
    }
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        let baseAttackRoll = HitDie.d20(1, 0).randomValue
        let armorClass = targetActor.armorClass

        var status = "miss"
        
        switch baseAttackRoll {
        case 0: status = "critical miss"
        case 20:
            let damage = self.actor.getMeleeAttackDamage(.maximum)
            status = "critical hit for \(damage) damage"
            self.targetActor.hitPoints.remove(hitPoints: damage)
        default:
            let attackRoll = baseAttackRoll + self.actor.meleeAttackBonus
            status = "\tAT \(attackRoll) vs AC \(armorClass): "
            if attackRoll > armorClass {
                let damage = self.actor.getMeleeAttackDamage(.random)
                status += "hit for \(damage) damage"
                self.targetActor.hitPoints.remove(hitPoints: damage)
            } else {
                status += "miss"
            }
        }
                        
        print(status)
        
        completion()
        
        return true
    }
}

