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
        let attackRoll = HitDie.d20(1, 0).randomValue + self.actor.rangedAttackBonus
        let armorClass = targetActor.armorClass

        var status = "\tAT \(attackRoll) vs AC \(armorClass): "

        if attackRoll - armorClass > 0 {
            let damage = self.actor.getRangedAttackDamage()
            status += "hit for \(damage) damage"
            self.targetActor.hitPoints.remove(hitPoints: damage)
        }
        else {
            status += "miss"
        }
        
        print(status)
        
        completion()
        
        return true
    }
}
