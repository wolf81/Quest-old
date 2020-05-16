//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum WieldStyle: String {
    case oneHanded
    case twoHanded
//    case dual

    init(rawValue: String) {
        switch rawValue {
        case "oneHanded": self = .oneHanded
        case "towHanded": self = .twoHanded
        default: fatalError()
        }
    }
}

class Weapon: Entity & Equippable, CustomStringConvertible {
    let attack: Int
    let damage: HitDie
    let range: Int
    let wieldStyle: WieldStyle
    
    var equipmentSlot: EquipmentSlot { .mainhand }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.attack = json["AT"] as? Int ?? 0
        self.range = json["range"] as? Int ?? 1

        let damage = json["damage"] as! String
        self.damage = HitDie(rawValue: damage)!
        
        let wield = json["wieldStyle"] as? String ?? "oneHanded"
        self.wieldStyle = WieldStyle(rawValue: wield)
        
        super.init(json: json, entityFactory: entityFactory)
    }
    
    static var none: Weapon { return self.init(json: ["damage": "0d0"], entityFactory: EntityFactory()) }
    
    static var fists: Weapon { return self.init(json: ["damage": "1d3"], entityFactory: EntityFactory()) }
    
    var description: String {
        return "{ attack: \(attack), damage: \(damage) }"
    }
}
