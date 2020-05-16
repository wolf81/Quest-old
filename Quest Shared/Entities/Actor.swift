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
                
    private let inventory: Inventory = Inventory()

    init(json: [String : Any], hitPoints: Int, armorClass: Int, skills: Skills, equipment: [Equippable], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.armorClass = armorClass
        self.skills = skills
        
        self.sight = json["sight"] as? Int32 ?? 6

        let actionCostJson = json["actionCost"] as? [String: Int] ?? [:]
        self.actionCost = ActionCost(json: actionCostJson)
        
        super.init(json: json, entityFactory: entityFactory)
                                
        self.hitPoints.delegate = self

        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
        
        for equipmentItem in equipment {
            self.inventory.equip(equipmentItem)
            self.sprite.addChild(equipmentItem.sprite)
        }
    }
    
    init(name: String, hitPoints: Int, race: Race, gender: Gender, attributes: Attributes, skills: Skills, equipment: [Equippable], backpack: [Lootable], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.skills = skills
        self.attributes = attributes
        
        super.init(json: ["name": name, "sprite": "\(race)_\(gender)"], entityFactory: entityFactory)
        
        self.hitPoints.delegate = self
        
        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
        
        for equipmentItem in equipment {
            self.inventory.equip(equipmentItem)
            self.sprite.addChild(equipmentItem.sprite)
        }
        
        self.inventory.append(backpack)
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: 1)
        self.skills = Skills(physical: 0, subterfuge: 0, knowledge: 0, communication: 0)
    
        super.init(json: json, entityFactory: entityFactory)

        self.hitPoints.delegate = self
        
        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
    }
    
    func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        dieRoll == .maximum ? self.inventory.weapon.damage.maxValue : self.inventory.weapon.damage.randomValue
    }

    func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        dieRoll == .maximum ? self.inventory.weapon.damage.maxValue : self.inventory.weapon.damage.randomValue
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
}

// MARK: - Equipment handling

extension Actor {
    var equippedWeapon: Weapon { self.inventory.equippedItems[.leftArm] as? Weapon ?? Weapon.fists }
    
    var equippedArmor: Armor { self.inventory.equippedItems[.chest] as? Armor ?? Armor.none }
    
    var equippedShield: Shield { self.inventory.equippedItems[.rightArm] as? Shield ?? Shield.none }
        
    func equippedItem(in equipmentSlot: EquipmentSlot) -> Equippable? { self.inventory.equippedItem(in: equipmentSlot) }

    @discardableResult
    func equipFromBackpack(at index: Int) -> Bool { self.inventory.equip(at: index) }

    @discardableResult
    func unequip(_ equipmentSlot: EquipmentSlot) -> Bool { self.inventory.unequip(equipmentSlot) }
}
