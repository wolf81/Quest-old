//
//  Inventory.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class Inventory {
    var backpack: [Lootable] = []
            
    private var equippedItems: [EquipmentSlot: Equippable] = [:]
    
    @discardableResult
    func equip(at index: Int) -> Bool {
        if let equipment = self.backpack[index] as? Equippable {
            unequip(equipment.equipmentSlot)

            remove(at: index)
            
            self.equippedItems[equipment.equipmentSlot] = equipment
            print("equip: \(equipment.name)")
            
            return true
        }
        
        return false
    }
    
    func equip(_ equipment: Equippable) {
        print("equip: \(equipment)")
        
        unequip(equipment.equipmentSlot)
        
        self.equippedItems[equipment.equipmentSlot] = equipment
    }
    
    @discardableResult
    func unequip(_ equipmentSlot: EquipmentSlot) -> Bool {
        if let equipment = self.equippedItems.removeValue(forKey: equipmentSlot) {
            print("unequip: \(equipment.name)")

            append(equipment)

            return true
        }
        
        
        return false
    }
    
    @discardableResult
    func append(_ loot: Lootable) -> Int {
        print("add to backpack: \(loot)")
        
        self.backpack.append(loot)
                
        return self.backpack.count
    }
    
    @discardableResult
    func append(_ loot: [Lootable]) -> Int {
        print("add to backpack: \(loot)")
        
        self.backpack.append(contentsOf: loot)

        return self.backpack.count
    }
        
    @discardableResult
    func remove(at index: Int) -> Lootable {
        print("remove from backpack item \(index)")
        
        return self.backpack.remove(at: index)
    }
    
    func equippedItem(in equipmentSlot: EquipmentSlot) -> Equippable? {
        return self.equippedItems[equipmentSlot]
    }
    
    subscript(index: Int) -> Lootable {
        return self.backpack[index]
    }
    
    var weapon: Weapon { self.equippedItems[.leftArm] as? Weapon ?? Weapon.none }
    
    var armor: Armor { self.equippedItems[.chest] as? Armor ?? Armor.none }
    
    var shield: Shield { self.equippedItems[.rightArm] as? Shield ?? Shield.none }
}


