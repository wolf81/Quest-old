//
//  Inventory.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class Inventory {
    private(set) var backpack: [Lootable] = []
            
    private(set) var equippedItems: [EquipmentSlot: Equippable] = [:]    
        
    init(entityFactory: EntityFactory) {}
    
    @discardableResult
    private func equip(at index: Int) -> Bool {
        if let equipment = self.backpack[index] as? Equippable {
            unequip(equipment.equipmentSlot)

            remove(at: index)                        
            
            self.equippedItems[equipment.equipmentSlot] = equipment
//            print("equip: \(equipment.name)")
            
            NotificationCenter.default.post(name: Notification.Name.actorDidChangeEquipment, object: nil)

            return true
        }
        
        return false
    }
    
    func equip(_ equipment: Equippable) {
//        print("equip: \(equipment)")
        
        unequip(equipment.equipmentSlot)
                
        self.equippedItems[equipment.equipmentSlot] = equipment
        
        NotificationCenter.default.post(name: Notification.Name.actorDidChangeEquipment, object: nil)
    }
        
    @discardableResult
    func unequip(_ equipmentSlot: EquipmentSlot) -> Bool {
        if let equipment = self.equippedItems.removeValue(forKey: equipmentSlot) {
//            print("unequip: \(equipment.name)")

            append(equipment)

            NotificationCenter.default.post(name: Notification.Name.actorDidChangeEquipment, object: nil)

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
        
    func use(at index: Int, with actor: Actor) {
        switch self.backpack[index] {
        case _ as Equippable:
            self.equip(at: index)
        case let item as Usable:
            item.use(actor: actor)
            remove(at: index)
        default: fatalError()
        }
    }
    
    func toggleEquippedWeapons() {
        let mainhand = self.equippedItems[.mainhand]
        let mainhand2 = self.equippedItems[.mainhand2]
        self.equippedItems[.mainhand] = mainhand2
        self.equippedItems[.mainhand2] = mainhand

        let offhand = self.equippedItems[.offhand]
        let offhand2 = self.equippedItems[.offhand2]
        self.equippedItems[.offhand] = offhand2
        self.equippedItems[.offhand2] = offhand
        
        NotificationCenter.default.post(name: Notification.Name.actorDidChangeEquipment, object: nil)
    }
}


