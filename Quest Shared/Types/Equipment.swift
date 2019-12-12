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
    var meleeWeapon: Weapon
    var rangedWeapon: Weapon
    var shield: Shield
    
    static var none: Equipment { return Equipment(armor: Armor.none, meleeWeapon: Weapon.none, rangedWeapon: .none) }
    
    init(armor: Armor, meleeWeapon: Weapon, rangedWeapon: Weapon = .none, shield: Shield = .none) {
        self.armor = armor
        self.meleeWeapon = meleeWeapon
        self.rangedWeapon = rangedWeapon
        self.shield = shield
    }
    
    init(json: [String: String], entityFactory: EntityFactory) {
        self.meleeWeapon = .none
        self.rangedWeapon = .none
        self.armor = .none
        self.shield = .none
        
        if let meleeWeaponName = json["melee_weapon"] as String? {
            do {
                self.meleeWeapon = try entityFactory.newEntity(name: meleeWeaponName) as! Weapon
            } catch let error {
                print(error)
            }
        }

        if let rangedWeaponName = json["ranged_weapon"] as String? {
            do {
                self.meleeWeapon = try entityFactory.newEntity(name: rangedWeaponName) as! Weapon
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
