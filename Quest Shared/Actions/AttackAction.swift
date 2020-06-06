//
//  AttackAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 30/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class AttackAction: Action, StatusUpdatable {
    public let targetActor: Actor
    
    private(set) var message: String?
    
    var isRanged: Bool { self.actor.isRangedWeaponEquipped }
    
    var hitState: HitState = .miss
    
    init(actor: Actor, targetActor: Actor) {
        self.targetActor = targetActor
        super.init(actor: actor)
    }
    
    override func perform(state: GameState) {
        let energyCost = getEnergyCost()
        self.actor.energy.drain(energyCost)
        
        let attackDie = HitDie.d20(1, 0)
        let baseAttackRoll = attackDie.randomValue
        let armorClass = targetActor.armorClass

        var status = "miss"
        
        switch baseAttackRoll {
        case attackDie.minValue:
            status = "critical miss"
            self.hitState = .criticalMiss
        case attackDie.maxValue:
            let damage = getDamage(.maximum)
            status = "critical hit for \(damage) damage"
            self.targetActor.reduceHealth(with: damage)
            self.hitState = .criticalHit
        default:
            let attackRoll = getAttack(baseAttackRoll)
            
            status = "AT \(attackRoll) vs AC \(armorClass): "
            if attackRoll > armorClass {
                let damage = getDamage(.random)
                status += "hit for \(damage) damage"
                self.targetActor.reduceHealth(with: damage)
                self.hitState = .hit

                if let hero = self.actor as? Hero, let monster = self.targetActor as? Monster, self.targetActor.hitPoints.current <= 0 {
                    hero.experience += monster.hitDie.dieCount
                }
            } else {
                status += "miss"
                self.hitState = .miss
            }
        }
        
        state.enterCombat(actor: self.actor)
        if self.hitState.isHit { state.enterCombat(actor: self.targetActor) }
        
        self.message = "\(self.actor.name) attacks \(self.targetActor.name): \(status)"
    }
    
    private func getEnergyCost() -> Int {
        guard self.isRanged else {
            return self.actor.energyCost.attackMelee
        }
        
        return self.actor.energyCost.attackRanged
    }
    
    private func getAttack(_ baseAttackRoll: Int) -> Int {
        let penalty = getAttackPenalty()

        guard self.isRanged else {
            return baseAttackRoll + self.actor.meleeAttackBonus + penalty
        }
        
        return baseAttackRoll + self.actor.rangedAttackBonus + penalty
    }
    
    private func getDamage(_ dieRoll: DieRoll) -> Int {
        guard self.isRanged else {
            return self.actor.getMeleeAttackDamage(dieRoll)
        }
        
        return self.actor.getRangedAttackDamage(dieRoll)
    }
    
    private func getAttackPenalty() -> Int {
        let distance = self.actor.coord &- self.targetActor.coord
        guard self.isRanged && (distance.x < 2 && distance.y < 2) else {
            return 0
        }
        
        return Constants.rangedWeaponMeleePenalty
    }
}
