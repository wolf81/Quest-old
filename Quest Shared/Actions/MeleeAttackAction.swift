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
    
    override func perform(game: Game, completion: @escaping () -> Void) -> Bool {
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

        let fromPosition = GameScene.pointForCoord(self.actor.coord)
        var toPosition = GameScene.pointForCoord(self.targetActor.coord)
        let xOffset = (fromPosition.x - toPosition.x) / 2
        let yOffset = (fromPosition.y - toPosition.y) / 2
        toPosition.x += xOffset
        toPosition.y += yOffset
        
        let attack = SKAction.sequence([
            SKAction.move(to: toPosition, duration: 3),
            SKAction.move(to: fromPosition, duration: 3),
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

