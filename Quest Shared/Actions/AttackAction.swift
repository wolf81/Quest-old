//
//  AttackAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class AttackAction: Action {
    public let targetActor: Actor
    
    init(actor: Actor, targetActor: Actor) {
        self.targetActor = targetActor
        super.init(actor: actor)
    }
    
    override var message: String {
        return "\(self.actor.name) (HP: \(self.actor.hitPoints.current) / \(self.actor.hitPoints.base)): ⚔ \(self.targetActor.name) (HP \(self.targetActor.hitPoints.current) / \(self.targetActor.hitPoints.base))"
    }
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        let attackRoll = HitDie.d20(1, 0).randomValue + self.actor.attackBonus
        let armorClass = targetActor.armorClass
        print("attack roll: \(attackRoll) vs \(armorClass)")
        if attackRoll - armorClass > 0 {
            let damage = self.actor.attackDamage()
            print("hit for \(damage) damage")
            self.targetActor.hitPoints.remove(hitPoints: damage)
        }
        else {
            print("miss")
        }
        
        completion()
        
        return true
    }
}

