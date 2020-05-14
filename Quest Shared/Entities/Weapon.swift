//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Weapon: Entity & Equippable, CustomStringConvertible {
    let attack: Int
    let damage: HitDie
    let range: Int
    
    var equipmentSlot: EquipmentSlot { .leftArm }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.attack = json["AT"] as? Int ?? 0
        self.range = json["range"] as? Int ?? 1

        let damage = json["damage"] as! String
        self.damage = HitDie(rawValue: damage)!
                
        super.init(json: json, entityFactory: entityFactory)
    }
    
    static var none: Weapon { return self.init(json: ["damage": "0d0"], entityFactory: EntityFactory()) }
    
    static var fists: Weapon { return self.init(json: ["damage": "1d3"], entityFactory: EntityFactory()) }
    
    var description: String {
        return "{ attack: \(attack), damage: \(damage) }"
    }
}
