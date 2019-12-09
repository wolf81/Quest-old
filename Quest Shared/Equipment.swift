//
//  Equipment.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

struct Equipment {
    var armor: Armor
    var weapon: Weapon
    
    static var none: Equipment { return Equipment(armor: Armor.none, weapon: Weapon.none) }
    
    init(armor: Armor, weapon: Weapon) {
        self.armor = armor
        self.weapon = weapon
    }
    
    init(json: [String: String], entityFactory: EntityFactory) {
        self.weapon = .none
        self.armor = .none
        
        if let weaponName = json["weapon"] as String? {
            self.weapon = entityFactory.newEntity(name: weaponName) as? Weapon ?? Weapon.none
        }
        
        if let armorName = json["armor"] as String? {
            self.armor = entityFactory.newEntity(name: armorName) as? Armor ?? Armor.none
        }
    }
}
