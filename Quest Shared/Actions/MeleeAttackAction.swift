//
//  AttackAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class MeleeAttackAction: Action, StatusUpdatable {
    public let targetActor: Actor
    
    private(set) var message: String?
    
    init(actor: Actor, targetActor: Actor, timeUnitCost: Int) {
        self.targetActor = targetActor
        super.init(actor: actor, timeUnitCost: timeUnitCost)
    }
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        defer {
            self.actor.subtractTimeUnits(self.timeUnitCost)
        }
        
        let attackDie = HitDie.d20(1, 0)
        let baseAttackRoll = attackDie.randomValue
        let armorClass = targetActor.armorClass

        var status = "miss"
        
        switch baseAttackRoll {
        case attackDie.minValue: status = "critical miss"
        case attackDie.maxValue:
            let damage = self.actor.getMeleeAttackDamage(.maximum)
            status = "critical hit for \(damage) damage"
            self.targetActor.hitPoints.remove(hitPoints: damage)
        default:
            let attackRoll = baseAttackRoll + self.actor.meleeAttackBonus
            status = "AT \(attackRoll) vs AC \(armorClass): "
            if attackRoll > armorClass {
                let damage = self.actor.getMeleeAttackDamage(.random)
                status += "hit for \(damage) damage"
                self.targetActor.hitPoints.remove(hitPoints: damage)
            } else {
                status += "miss"
            }
        }

        self.message = "\(self.actor.name) attacks \(self.targetActor.name): \(status)"

        let attack = SKAction.sequence([
            SKAction.wait(forDuration: 6),
            SKAction.run({
                DispatchQueue.main.async {
                    completion()
                }
            })
        ])
        self.actor.sprite.run(attack)
                        
        return true
    }
}

