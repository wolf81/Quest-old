//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Weapon: Entity, CustomStringConvertible {
    let attack: Int
    let damage: HitDice
    
    required init(json: [String : Any]) {
        let attack = json["AT"] as? Int ?? 0
        self.attack = attack
        
        let damage = json["damage"] as! String
        self.damage = HitDice(rawValue: damage)!
        
        super.init(json: json)
    }
    
    static var none: Weapon {
        get {
            return self.init(json: ["damage": "0d4"])
        }
    }
    
    var description: String {
        return "{ attack: \(attack), damage: \(damage) }"
    }
}
