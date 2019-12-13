//
//  RangedAttackAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class RangedAttackAction: Action {
    public let targetActor: Actor
       
    override var message: String {
        return "[\(self.actor.name)] ↣ \(self.targetActor.name) (\(self.targetActor.hitPoints.current)/\(self.targetActor.hitPoints.base))"
    }

    init(actor: Actor, targetActor: Actor) {
        self.targetActor = targetActor
        super.init(actor: actor)
    }
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        let baseAttackRoll = HitDie.d20(1, 0).randomValue
        let armorClass = targetActor.armorClass

        var status = "miss"
        
        switch baseAttackRoll {
        case 0: status = "critical miss"
        case 20:
            let damage = self.actor.getRangedAttackDamage(.maximum)
            status = "critical hit for \(damage) damage"
            self.targetActor.hitPoints.remove(hitPoints: damage)
        default:
            let attackRoll = baseAttackRoll + self.actor.rangedAttackBonus
            if attackRoll > armorClass {
                var status = "\tAT \(attackRoll) vs AC \(armorClass): "
                let damage = self.actor.getRangedAttackDamage(.random)
                status += "hit for \(damage) damage"
                self.targetActor.hitPoints.remove(hitPoints: damage)
            }
        }
                        
        print(status)
        
        completion()
        
        return true
    }
}
