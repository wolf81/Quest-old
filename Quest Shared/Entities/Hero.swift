//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Hero: Actor, CustomStringConvertible {
    let race: Race
    let role: Role
    
    override var level: Int { return 1 }
        
    private var direction: Direction?
        
    private var path: [vector_int2]?
    
    private var meleeTarget: Actor?
    
    private var rangedTarget: Actor?
        
    private var spell: Spell?
        
    override var meleeAttackBonus: Int {
        var attackBonus = self.attributes.strength.bonus + self.inventory.weapon.attack
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
    
    override var rangedAttackBonus: Int {
        var attackBonus = self.attributes.dexterity.bonus + self.inventory.weapon.attack
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
        
    override func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        self.attributes.strength.bonus + (dieRoll == .maximum
            ? self.inventory.weapon.damage.maxValue
            : self.inventory.weapon.damage.randomValue)
    }
    
    override func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        return dieRoll == .maximum
            ? self.inventory.weapon.damage.maxValue
            : self.inventory.weapon.damage.randomValue
    }

    override var armorClass: Int {
        10 + attributes.dexterity.bonus + self.inventory.armor.armorClass + self.inventory.shield.armorClass
    }
    
    public init(name: String, race: Race, gender: Gender, role: Role, attributes: Attributes, skills: Skills, entityFactory: EntityFactory) {
        self.race = race
        self.role = role
                
        let equipment = Hero.initialEquipmentFor(role, entityFactory: entityFactory)
        let backpack = Hero.initialBackpackFor(role, entityFactory: entityFactory)
        
        let hitPoints = HitDie.d6(1, 0).maxValue + attributes.strength.bonus // 1d6 + STR bonus per level, for first level use max health
        super.init(name: name, hitPoints: hitPoints, race: race, gender: gender, attributes: attributes, skills: skills, equipment: equipment, backpack: backpack, entityFactory: entityFactory)
    }

    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.race = .human
        self.role = .fighter

        super.init(json: json, entityFactory: entityFactory)
    }
    
    func move(path: [vector_int2]) {
        self.path = path
    }
    
    func move(direction: Direction) {
        self.direction = direction
    }
    
    func cast(spell: Spell) {
        self.spell = spell
    }
    
    func attackMelee(actor: Actor) {
        self.meleeTarget = actor
    }
    
    func attackRanged(actor: Actor) {
        self.rangedTarget = actor
    }
    
    var description: String {
        return """
        \(self.name)
        \t\(self.race) \(self.role) (\(self.hitPoints))
        \t\(self.attributes)
        \t\(self.skills)
        \tAC: \(self.armorClass)
        \tATT: \(self.meleeAttackBonus)
        \tDMG: \(self.getMeleeAttackDamage(.maximum))
        """
    }
    
    override func getAction(state: Game) -> Action? {
        defer {
            self.path = nil
            self.direction = nil
            self.meleeTarget = nil
            self.rangedTarget = nil
            self.spell = nil
        }

        if self.isAlive == false {
            return DieAction(actor: self, timeUnitCost: Constants.timeUnitsPerTurn)
        }
        
        if let direction = self.direction {
            let toCoord = self.coord &+ direction.coord
            
            if let targetActor = state.getActorAt(coord: toCoord) {                
                return MeleeAttackAction(actor: self, targetActor: targetActor, timeUnitCost: self.actionCost.meleeAttack)
            }
            
            if state.canMove(entity: self, toCoord: toCoord) {
                return MoveAction(actor: self, toCoord: toCoord, timeUnitCost: self.actionCost.move)
            }
        } else if let path = self.path {
            return MoveAction(actor: self, coords: path, timeUnitCost: self.actionCost.move)
        } else if let meleeTarget = self.meleeTarget {
            return MeleeAttackAction(actor: self, targetActor: meleeTarget, timeUnitCost: self.actionCost.meleeAttack)
        } else if let rangedTarget = self.rangedTarget {
            return RangedAttackAction(actor: self, targetActor: rangedTarget, timeUnitCost: self.actionCost.rangedAttack)
        } else if let spell = self.spell {
            return CastSpellAction(actor: self, spell: spell, timeUnitCost: Constants.timeUnitsPerTurn)
        }
                             
        return nil
    }
        
    private static func initialBackpackFor(_ role: Role, entityFactory: EntityFactory) -> [Lootable] {
        let lootInfo = [
            "weapon": "Battleaxe +3",
        ]
        
        var loot: [Lootable] = []
        for (typeName, itemName) in lootInfo {
            let item = try! entityFactory.newEntity(typeName: typeName.capitalized, name: itemName) as! Lootable
            loot.append(item)
        }
        
        return loot
    }
    
    private static func initialEquipmentFor(_ role: Role, entityFactory: EntityFactory) -> [Equippable] {
        var equipmentInfo: [String: String] = [:]
        
        switch role {
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
