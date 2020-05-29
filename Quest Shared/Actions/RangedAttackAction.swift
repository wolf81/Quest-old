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

    private(set) var isHit: Bool = false
    
    private(set) var message: String?
    
//    override var message: String {
//        return "[\(self.actor.name)] ↣ \(self.targetActor.name) (\(self.targetActor.hitPoints.current)/\(self.targetActor.hitPoints.base))"
//    }

    init(actor: Actor, targetActor: Actor) {
        self.targetActor = targetActor
        super.init(actor: actor)
    }
    
    override func perform(state: GameState) {
        self.actor.energy.drain(self.actor.energyCost.attackRanged)

        let attackDie = HitDie.d20(1, 0)
        let baseAttackRoll = attackDie.randomValue
        let armorClass = targetActor.armorClass

        var status = "miss"
        
        switch baseAttackRoll {
        case attackDie.minValue: status = "critical miss"
        case attackDie.maxValue:
            self.isHit = true
            let damage = self.actor.getRangedAttackDamage(.maximum)
            status = "critical hit for \(damage) damage"
            self.targetActor.reduceHealth(with: damage)
        default:
            let distance = self.actor.coord &- self.targetActor.coord
            let meleePenalty = (distance.x < 2 && distance.y < 2) ? Constants.rangedWeaponMeleePenalty : 0
            let attackRoll = baseAttackRoll + self.actor.rangedAttackBonus + meleePenalty
            status = "\tAT \(attackRoll) vs AC \(armorClass): "
            if attackRoll > armorClass {
                self.isHit = true
                let damage = self.actor.getRangedAttackDamage(.random)
                status += "hit for \(damage) damage"
                self.targetActor.reduceHealth(with: damage)
            } else {
                status += "miss"
            }
        }
                                
        self.message = status        
    }
}
