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
    
    override func update(state: Game) {
        guard self.isAlive else {
            let die = DieAction(actor: self)
            return setAction(die)
        }
                
        // If hero is in melee range, perform melee attack
        let xRange = self.coord.x - 1 ... self.coord.x + 1
        let yRange = self.coord.y - 1 ... self.coord.y + 1
        if state.hero.isAlive && xRange.contains(state.hero.coord.x) && yRange.contains(state.hero.coord.y) {
            guard self.energy.amount >= self.energyCost.attack else { return }
            let attack = MeleeAttackAction(actor: self, targetActor: state.hero)
            return setAction(attack)
        }
                
        if state.actorVisibleCoords.contains(state.hero.coord) {
            guard self.energy.amount >= self.energyCost.move else { return }
            let actorCoords = state.activeActors.filter({ $0.coord != self.coord && $0.coord != state.hero.coord }).compactMap({ $0.coord })
            let movementGraph = state.getMovementGraph(for: self, range: self.sight, excludedCoords: actorCoords)
            if let actorNode = movementGraph.node(atGridPosition: self.coord), let heroNode = movementGraph.node(atGridPosition: state.hero.coord)  {
                var pathNodes = movementGraph.findPath(from: actorNode, to: heroNode) as! [GKGridGraphNode]
                pathNodes.removeLast() // we don't want to move on top of the hero

                let moveCount = 1
                
                if pathNodes.count > 0 && moveCount > 0 {
                    let nodeCount = pathNodes.count
                    
                    let removeNodeCount = max(nodeCount - moveCount - 1, 0)
                    pathNodes.removeLast(removeNodeCount)
                                        
                    let path = pathNodes.compactMap({ $0.gridPosition })
                    let move = MoveAction(actor: self, coords: path)
                    return setAction(move)
                }
            }
        }
        
        let idle = IdleAction(actor: self)
        setAction(idle)
    }
}

