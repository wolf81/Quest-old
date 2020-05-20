//
//  RangedAttackAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class RangedAttackAction: Action, StatusUpdatable {
    public let targetActor: Actor

    private(set) var message: String?
    
//    override var message: String {
//        return "[\(self.actor.name)] ↣ \(self.targetActor.name) (\(self.targetActor.hitPoints.current)/\(self.targetActor.hitPoints.base))"
//    }

    init(actor: Actor, targetActor: Actor, timeUnitCost: Int) {
        self.targetActor = targetActor
        super.init(actor: actor, timeUnitCost: timeUnitCost)
    }
    
    override func perform(game: Game) {
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
            let damage = self.actor.getRangedAttackDamage(.maximum)
            status = "critical hit for \(damage) damage"
            self.targetActor.hitPoints.remove(hitPoints: damage)
        default:
            let attackRoll = baseAttackRoll + self.actor.rangedAttackBonus
            status = "\tAT \(attackRoll) vs AC \(armorClass): "
            if attackRoll > armorClass {
                let damage = self.actor.getRangedAttackDamage(.random)
                status += "hit for \(damage) damage"
                self.targetActor.hitPoints.remove(hitPoints: damage)
            } else {
                status += "miss"
            }
        }
                                
        self.message = status
        
//        let attack = SKAction.sequence([
//            SKAction.wait(forDuration: 6),
//            SKAction.run {
//                completion()
//            }
//        ])

//        self.actor.sprite.run(attack)        
    }
}
