//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum DieRoll {
    case random
    case maximum
}

class Actor: Entity {
    var hitPoints: HitPoints

    var isAlive: Bool { return self.hitPoints.current > 0 }

    private(set) var skills: Skills
        
    private(set) var attributes: Attributes = Attributes(strength: 12, dexterity: 12, mind: 12)

    private(set) var actionCost: ActionCost = ActionCost()
    
    private(set) var meleeAttackBonus: Int = 0

    private(set) var rangedAttackBonus: Int = 0

    private(set) var armorClass: Int = 0
        
    private(set) var sight: Int32 = 4
    
    private(set) var level: Int = 1
    
    private(set) var timeUnits: Int = 0
    
    private(set) var healthBar: HealthBar!
    
    private(set) var unarmed: Weapon
                
    private let inventory: Inventory = Inventory()
    
    private var action: Action?
    
    func setAction(_ action: Action) {
        self.action = action
    }
    
    func getAction() -> Action? {
        defer {
            self.action = nil
        }
        
        return action
    }
    
    func update(state: Game) { fatalError() }

    init(json: [String : Any], hitPoints: Int, armorClass: Int, skills: Skills, equipment: [Equippable], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.armorClass = armorClass
        self.skills = skills
        self.unarmed = try! entityFactory.newEntity(type: Weapon.self, name: "Unarmed")
        
        self.sight = json["sight"] as? Int32 ?? 6

        let actionCostJson = json["actionCost"] as? [String: Int] ?? [:]
        self.actionCost = ActionCost(json: actionCostJson)
        
        super.init(json: json, entityFactory: entityFactory)
                                
        self.hitPoints.delegate = self

        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
        
        equipment.forEach({ self.inventory.equip($0 )})
        updateSpriteForEquipment()
    }
    
    init(name: String, hitPoints: Int, race: Race, gender: Gender, attributes: Attributes, skills: Skills, equipment: [Equippable], backpack: [Lootable], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.skills = skills
        self.attributes = attributes
        self.unarmed = try! entityFactory.newEntity(type: Weapon.self, name: "Unarmed")

        super.init(json: ["name": name, "sprite": "\(race)_\(gender)"], entityFactory: entityFactory)
        
        self.hitPoints.delegate = self
        
        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
        
        self.inventory.append(backpack)
        
        equipment.forEach({ self.inventory.equip($0 )})
        updateSpriteForEquipment()
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: 1)
        self.skills = Skills(physical: 0, subterfuge: 0, knowledge: 0, communication: 0)
        self.unarmed = try! entityFactory.newEntity(type: Weapon.self, name: "Unarmed")

        super.init(json: json, entityFactory: entityFactory)

        self.hitPoints.delegate = self
        
        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
    }
    
    func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        dieRoll == .maximum ? self.equippedWeapon.damage.maxValue : self.equippedWeapon.damage.randomValue
    }

    func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        dieRoll == .maximum ? self.equippedWeapon.damage.maxValue : self.equippedWeapon.damage.randomValue
    }
    
    func addTimeUnits(_ timeUnits: Int) {
        self.timeUnits = min(self.timeUnits + timeUnits, Constants.timeUnitsPerTurn * 2)
    }
    
    func subtractTimeUnits(_ timeUnits: Int) {
        self.timeUnits = max(self.timeUnits - timeUnits, 0)
    }

    func getAction(state: Game) -> Action? {
        return nil
    }
        
    func updateSpriteForEquipment() {
        let children = self.sprite.children.filter({ $0 != self.healthBar })
        for child in children {
            child.removeFromParent()
        }
        
        for (_, equipment) in self.inventory.equippedItems {
            self.sprite.addChild(equipment.sprite)
        }
    }
    
    // MARK: - Private
    
    private static func addHealthBar(sprite: SKSpriteNode) -> HealthBar {
        let barWidth = sprite.frame.width - 6
        let healthBar = HealthBar(size: CGSize(width: barWidth, height: 6))
        healthBar.position = CGPoint(x: -(barWidth / 2), y: (sprite.frame.height / 2) + 4)
        sprite.addChild(healthBar)
        return healthBar
    }
}

extension Actor: HitPointsDelegate {
    func hitPointsChanged(current: Int, total: Int) {
        let percentageHealth = CGFloat(current) / CGFloat(total)
        self.healthBar.update(health: percentageHealth)
    }
}

// MARK: Backpack handling

extension Actor {
    var backpackItemCount: Int { self.inventory.backpack.count }
    
    func backpackItem(at index: Int) -> Lootable { self.inventory.backpack[index] }

    @discardableResult
    func addToBackpack(_ loot: Lootable) -> Int { self.inventory.append(loot) }
    
    @discardableResult
    func addToBackpack(_ loot: [Lootable]) -> Int { self.inventory.append(loot) }
        
    @discardableResult
    func removeFromBackpack(at index: Int) -> Lootable { self.inventory.remove(at: index) }
    
    @objc
    func useBackpackItem(at index: Int) {
        if let weapon = self.backpackItem(at: index) as? Weapon, weapon.style == .twoHanded {
            self.inventory.unequip(.offhand)
        }
        
        if let armor = self.backpackItem(at: index) as? Armor, armor.equipmentSlot == .offhand, self.equippedWeapon.style == .twoHanded {
            self.inventory.unequip(.mainhand)
        }

        self.inventory.use(at: index, with: self)
    }
}

// MARK: - Equipment handling

extension Actor {
    var equippedWeapon: Weapon { self.inventory.equippedItems[.mainhand] as? Weapon ?? self.unarmed }
    
    var equippedArmor: Armor { self.inventory.equippedItems[.chest] as? Armor ?? Armor.none }
    
    var equippedShield: Armor { self.inventory.equippedItems[.offhand] as? Armor ?? Armor.none }
        
    func equippedItem(in equipmentSlot: EquipmentSlot) -> Equippable? { self.inventory.equippedItem(in: equipmentSlot) }

    @discardableResult
    func unequip(_ equipmentSlot: EquipmentSlot) -> Bool { self.inventory.unequip(equipmentSlot) }
}
