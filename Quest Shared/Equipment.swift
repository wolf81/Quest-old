//
//  Equipment.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

enum EquipmentError: LocalizedError {
    case unknownEntity(String)
}

struct Equipment {
    var armor: Armor
    var weapon: Weapon
    var shield: Shield
    
    static var none: Equipment { return Equipment(armor: Armor.none, weapon: Weapon.none) }
    
    init(armor: Armor, weapon: Weapon, shield: Shield = .none) {
        self.armor = armor
        self.weapon = weapon
        self.shield = shield
    }
    
    init(json: [String: String], entityFactory: EntityFactory) {
        self.weapon = .none
        self.armor = .none
        self.shield = .none
        
        if let weaponName = json["weapon"] as String? {
            do {
                self.weapon = try entityFactory.newEntity(name: weaponName) as! Weapon
            } catch let error {
                print(error)
            }
        }
        
        if let armorName = json["armor"] as String? {
            do {
                self.armor = try entityFactory.newEntity(name: armorName) as! Armor
            } catch let error {
                print(error)
            }
        }
    }
}
