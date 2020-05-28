//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation
import GameplayKit

class Monster: Actor, CustomStringConvertible {
    let hitDie: HitDie
                    
    override var meleeAttackBonus: Int { self.equippedWeapon.attack }
    
    override var isAwaitingInput: Bool { false }
    
    override func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        dieRoll == .maximum ? self.equippedWeapon.damage.maxValue : self.equippedWeapon.damage.randomValue
    }

    required init(json: [String : Any], entityFactory: EntityFactory) {
        let hitDieString = json["HD"] as! String
        let hitDie = HitDie(rawValue: hitDieString)!
        self.hitDie = hitDie
        
        let hitPoints = (self.hitDie.minValue + self.hitDie.maxValue) / 2
        let armorClass = json["AC"] as! Int
        
        let skillInfo = json["skills"] as? [String: Int] ?? [:]
        let skills = Skills(json: skillInfo, defaultValue: hitDie.dieCount)
        
        var equipment: [Equippable] = []
        let equipmentInfo = json["EQ"] as? [String: String] ?? [:]
        for (type, name) in equipmentInfo {
            equipment.append(try! entityFactory.newEntity(typeName: type.capitalized, name: name) as! Equippable)
        }
                
        super.init(json: json, hitPoints: hitPoints, armorClass: armorClass, skills: skills, equipment: equipment, entityFactory: entityFactory)
    }
        
    var description: String {
        return "\(self.name) [ HD: \(self.hitDie) / HP: \(self.hitPoints.current) / AC: \(self.armorClass) ]"
    }
        
    override func update(state: GameState) {
        guard self.isAlive && state.hero.isAlive else { return idle() }

        let didMeleeAttack = attack(meleeTarget: state.hero, state: state)
        guard didMeleeAttack == false else { return }

        let didRangedAttack = attack(rangedTarget: state.hero, state: state)
        guard didRangedAttack == false else { return }
        
        let didMove = move(to: state.hero, state: state)
        guard didMove == false else { return }        
    }
    
    // MARK: - Private
    
    private func attack(rangedTarget: Actor, state: GameState) -> Bool {
        guard self.visibleCoords.contains(rangedTarget.coord) else { return false }

        let coords = Functions.coordsBetween(self.coord, rangedTarget.coord)
        let nodes = coords.compactMap({ state.getMapNode(at: $0) })
        let isBlocked = nodes.contains(.blocked)
        let isRangedWeaponEquipped = self.equippedWeapon.range > 1
        // if the hero is not blocked by walls and we carry a ranged weapon, shoot on the hero
        
        guard isBlocked == false && isRangedWeaponEquipped else { return false }
        
        let x = pow(Float(rangedTarget.coord.x - self.coord.x), 2)
        let y = pow(Float(rangedTarget.coord.x - self.coord.x), 2)
        let distance = Int(sqrt(x + y))

        guard distance <= self.equippedWeapon.range else { return false }

        let attack = RangedAttackAction(actor: self, targetActor: rangedTarget)
        setAction(attack)

        return true
    }
    
    private func attack(meleeTarget: Actor, state: GameState) -> Bool {
        // If hero is in melee range, perform melee attack
        let xRange = self.coord.x - 1 ... self.coord.x + 1
        let yRange = self.coord.y - 1 ... self.coord.y + 1
        let targetInMeleeRange = xRange.contains(meleeTarget.coord.x) && yRange.contains(meleeTarget.coord.y)
        
        guard targetInMeleeRange else { return false }

        let attack = MeleeAttackAction(actor: self, targetActor: meleeTarget)
        setAction(attack)
        return true
    }
    
    private func idle() {
        setAction(IdleAction(actor: self))
    }
    
    private func move(to actor: Actor, state: GameState) -> Bool {
        guard self.visibleCoords.contains(actor.coord) else { return false }
        
        let path = state.findPath(from: self.coord, to: actor.coord)
        
        guard path.count > 0 else { return false }

        let toCoord = path[1]
        
        guard state.canMove(entity: self, to: toCoord) else { return false }
        
        let move = MoveAction(actor: self, coords: [toCoord])
        setAction(move)
        
        return true
    }
}

