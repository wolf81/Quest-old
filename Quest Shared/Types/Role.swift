//
//  Role.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

enum Role: String, Codable {
    case fighter
    case rogue
    case mage
    case cleric
    
    func canEquip(_ equippable: Equippable) -> Bool {
        if let armor = equippable as? Armor {
            let armorRestrictionInfo: [Armor.ArmorType: [Role]] = [
                .light: [.rogue, .cleric, .fighter, .mage],
                .medium: [.rogue, .cleric, .fighter],
                .heavy: [.cleric, .fighter]
            ]

            if let validRoles = armorRestrictionInfo[armor.type] {
                return validRoles.contains(self)
            }
        } else if let weapon = equippable as? Weapon {
            if self == .mage && weapon.type == .staff { return true }
            
            let weaponRestrictionInfo: [Weapon.WeaponCategory: [Role]] = [
                .light: [.fighter, .cleric, .mage],
                .medium: [.fighter, .cleric],
                .heavy: [.fighter]
            ]

            if let validRoles = weaponRestrictionInfo[weapon.category] {
                return validRoles.contains(self)
            }
        }
        
        return true
    }
    
    func defaultBackpack(entityFactory: EntityFactory) -> [Lootable] {
        let lootInfo = [
            "weapon": "Battleaxe +3",
            "armor": "Chainmail",
        ]
        
        var loot: [Lootable] = []
        for (typeName, itemName) in lootInfo {
            let item = try! entityFactory.newEntity(typeName: typeName.capitalized, name: itemName) as! Lootable
            loot.append(item)
        }
        
        return loot
    }
    
    func defaultEquipment(entityFactory: EntityFactory) -> [Equippable] {
        var equipmentInfo: [String: String] = [:]
        
        switch self {
        case .fighter:
            equipmentInfo = [
                "armor": "Chainmail",
                "weapon": "Longsword",
                "shield": "Buckler"
            ]
        case .mage:
            equipmentInfo = [
                "armor": "Robe",
                "weapon": "Quarterstaff",
            ]
        case .cleric:
            equipmentInfo = [
                "armor": "Chainmail",
                "weapon": "Mace",
                "shield": "Buckler"
            ]
        case .rogue:
            equipmentInfo = [
                "armor": "Studded Leather",
                "weapon": "Shortsword",
            ]
        }
        
        var equipment: [Equippable] = []
        for (typeName, itemName) in equipmentInfo {
            let item = try! entityFactory.newEntity(typeName: typeName.capitalized, name: itemName) as! Equippable
            equipment.append(item)
        }
        
        return equipment
    }
}
