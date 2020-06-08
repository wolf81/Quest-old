//
//  Inventory.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class Inventory {
    private(set) var backpack: [Lootable] = []
            
    private var equippedItems: [EquipmentSlot: Equippable] = [:]
    
    private let noneRing: Accessory
    
    private let noneHeadpiece: Accessory
    
    private let noneBoots: Accessory

    private let noneArmor: Armor

    private let unarmed: Weapon
    
    var equipmentSprites: [SKSpriteNode] {
        let excludedSlots: [EquipmentSlot] = [.ring, .mainhand2, .offhand2]
        let equipment = Array(self.equippedItems.values)
        return equipment.filter({ excludedSlots.contains($0.equipmentSlot) == false }).compactMap({ $0.equipSprite })
    }
        
    init(entityFactory: EntityFactory) {
        self.noneRing = try! entityFactory.newEntity(type: Accessory.self, name: "None Ring")
        self.noneHeadpiece = try! entityFactory.newEntity(type: Accessory.self, name: "None Headpiece")
        self.noneBoots = try! entityFactory.newEntity(type: Accessory.self, name: "None Boots")
        self.noneArmor = try! entityFactory.newEntity(type: Armor.self, name: "None Armor")
        self.unarmed = try! entityFactory.newEntity(type: Weapon.self, name: "Unarmed")
    }
    
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
        guard let item = self.equippedItems[equipmentSlot] else {
            switch equipmentSlot {
            case .head: return self.noneHeadpiece
            case .ring: return self.noneRing
            case .feet: return self.noneBoots
            case .mainhand, .mainhand2: return self.unarmed
            case .offhand, .offhand2: return self.noneArmor
            case .chest: return self.noneArmor
            default: fatalError()
            }
        }
        
        return item
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


