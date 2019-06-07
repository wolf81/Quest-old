//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class Monster: Creature, CustomStringConvertible {
    let hitDice: HitDice
    let armorClass: Int
    
    required init(json: [String : Any]) {
        let hitDice = json["HD"] as! String
        self.hitDice = HitDice(rawValue: hitDice)!
        
        self.armorClass = json["AC"] as! Int
        
        super.init(json: json)

        self.sprite.zPosition = 100
    }
    
    var description: String {
        return "\(self.name) [ HD: \(self.hitDice) / AC: \(armorClass) ]"
    }
}

