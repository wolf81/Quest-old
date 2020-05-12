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

typealias Equipment = [EquipmentSlot: Equippable]

extension Equipment {
    var weapon: Weapon { self[.leftArm] as? Weapon ?? Weapon.none }
    
    var armor: Armor { self[.chest] as? Armor ?? Armor.none }
    
    var shield: Shield { self[.rightArm] as? Shield ?? Shield.none }
        
    init(json: [String: String], entityFactory: EntityFactory) {
        self.init()
        
        if let meleeWeaponName = json["weapon"] as String? {
            do {
                self[.leftArm] = try entityFactory.newEntity(type: Weapon.self, name: meleeWeaponName)
            } catch let error {
                print(error)
            }
        }

        if let armorName = json["armor"] as String? {
            do {
                self[.chest] = try entityFactory.newEntity(type: Armor.self, name: armorName)
            } catch let error {
                print(error)
            }
        }
    }
}


//struct Equipment {
//    var chest: Equippable?
//    var leftArm: Equippable?
//    var rightArm: Equippable?
//    var legs: Equippable?
//
//    var weapon: Weapon { self.leftArm as? Weapon ?? Weapon.none }
//
//    var shield: Shield { self.rightArm as? Shield ?? Shield.none }
//
//    var armor: Armor { self.chest as? Armor ?? Armor.none }
//
//    init() { }
//
//    init(json: [String: String], entityFactory: EntityFactory) {
//        if let meleeWeaponName = json["weapon"] as String? {
//            do {
//                self.leftArm = try entityFactory.newEntity(type: Weapon.self, name: meleeWeaponName)
//            } catch let error {
//                print(error)
//            }
//        }
//
//        if let armorName = json["armor"] as String? {
//            do {
//                self.chest = try entityFactory.newEntity(type: Armor.self, name: armorName)
//            } catch let error {
//                print(error)
//            }
//        }
//    }
//}
