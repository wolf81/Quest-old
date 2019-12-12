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
                    
    override var meleeAttackBonus: Int { return self.equipment.meleeWeapon.attack }
    
    override func getMeleeAttackDamage() -> Int { return self.equipment.meleeWeapon.damage.randomValue }

    required init(json: [String : Any]) {
        let hitDieString = json["HD"] as! String
        let hitDie = HitDie(rawValue: hitDieString)!
        self.hitDie = hitDie
        
        let hitPoints = (self.hitDie.minValue + self.hitDie.maxValue) / 2
        let armorClass = json["AC"] as! Int
        
        let skillInfo = json["skills"] as? [String: Int] ?? [:]
        let skills = Skills(json: skillInfo, defaultValue: hitDie.dieCount)
        
        let equipmentInfo = json["EQ"] as? [String: String] ?? [:]
        let equipment = Equipment(json: equipmentInfo, entityFactory: Entity.entityFactory)
        super.init(json: json, hitPoints: hitPoints, armorClass: armorClass, skills: skills, equipment: equipment)

        self.sprite.zPosition = 100
    }
        
    var description: String {
        return "\(self.name) [ HD: \(self.hitDie) / HP: \(self.hitPoints.current) / AC: \(self.armorClass) ]"
    }
    
    override func getAction(state: Game) -> Action? {
        if self.isAlive == false {
            return DieAction(actor: self)
        }
        
//        let directions: [Direction] = [.up, .down, .left, .right]
//        let randomDirection = directions.randomElement()
        
        // If hero is in melee range, perform melee attack
        let xRange = self.coord.x - 1 ... self.coord.x + 1
        let yRange = self.coord.y - 1 ... self.coord.y + 1
        if state.hero.isAlive && xRange.contains(state.hero.coord.x) && yRange.contains(state.hero.coord.y) {
            return MeleeAttackAction(actor: self, targetActor: state.hero)
        }
                
        if state.isHeroVisible(for: self) {
            let actorCoords = state.actors.filter({ $0.coord != self.coord && $0.coord != state.hero.coord }).compactMap({ $0.coord })
            let movementGraph = state.getMovementGraph(for: self, range: self.sight, excludedCoords: actorCoords)
            if let actorNode = movementGraph.node(atGridPosition: self.coord), let heroNode = movementGraph.node(atGridPosition: state.hero.coord)  {
                var pathNodes = movementGraph.findPath(from: actorNode, to: heroNode) as! [GKGridGraphNode]
                if pathNodes.count > 0 {
                    pathNodes.removeLast()

                    if pathNodes.count > self.speed {
                        pathNodes.removeLast(pathNodes.count - self.speed)
                    }
                    
                    let path = pathNodes.compactMap({ $0.gridPosition })
                    return MoveAction(actor: self, coords: path)
                }
            }
        }
        
//        // Move in random direction
//        let toCoord = self.coord &+ randomDirection!.coord
//        if state.canMove(entity: self, toCoord: toCoord) {
//            return MoveAction(actor: self, toCoord: toCoord)
//        }

        return IdleAction(actor: self)
    }
}

