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
    let armorClass: Int
        
    required init(json: [String : Any]) {
        let hitDice = json["HD"] as! String
        self.hitDice = HitDice(rawValue: hitDice)!
        
        let hitPoints = (self.hitDice.minValue + self.hitDice.maxValue) / 2
        
        self.armorClass = json["AC"] as! Int
        
        super.init(json: json, hitPoints: hitPoints)

        self.sprite.zPosition = 100
    }
    
    var description: String {
        return "\(self.name) [ HD: \(self.hitDice) / HP: \(self.hitPoints - self.damage) / AC: \(self.armorClass) ]"
    }
    
    override func getAction() -> Action? {
        return IdleAction(actor: self)
    }
}

