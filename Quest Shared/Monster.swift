//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class Monster: Actor, CustomStringConvertible {
    let hitDice: HitDice
                    
    required init(json: [String : Any]) {
        let hitDiceString = json["HD"] as! String
        let hitDice = HitDice(rawValue: hitDiceString)!
        self.hitDice = hitDice
        
        let hitPoints = (self.hitDice.minValue + self.hitDice.maxValue) / 2
        let armorClass = json["AC"] as! Int
        
        let skillInfo = json["skills"] as? [String: Int] ?? [:]
        let skills = Skills(json: skillInfo, defaultValue: hitDice.diceCount)
        
        super.init(json: json, hitPoints: hitPoints, armorClass: armorClass, skills: skills)

        self.sprite.zPosition = 100
    }
    
    var description: String {
        return "\(self.name) [ HD: \(self.hitDice) / HP: \(self.hitPoints - self.damage) / AC: \(self.armorClass) ]"
    }
    
    override func getAction(state: Game) -> Action? {
        let directions: [Direction] = [.up, .down, .left, .right]
        let randomDirection = directions.randomElement()
        
        let toCoord = self.coord &+ randomDirection!.coord
        
        if let targetActor = state.getActorAt(coord: toCoord) {
            if targetActor is Hero {
                return AttackAction(actor: self, targetActor: targetActor)
            }
        }
        
        if state.canMoveEntity(entity: self, toCoord: toCoord) {
            return MoveAction(actor: self, toCoord: toCoord)
        }

        return IdleAction(actor: self)
    }
}

