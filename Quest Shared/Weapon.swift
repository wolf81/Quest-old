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
    let damage: HitDie
    
    required init(json: [String : Any]) {
        let attack = json["AT"] as? Int ?? 0
        self.attack = attack
        
        let damage = json["damage"] as! String
        self.damage = HitDie(rawValue: damage)!
        
        super.init(json: json)
    }
    
    static var none: Weapon { return self.init(json: ["damage": "1d3"]) }
    
    var description: String {
        return "{ attack: \(attack), damage: \(damage) }"
    }
}
