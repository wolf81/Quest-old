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
        
    var experience: Int = 0
    
    private var direction: Direction?
                
    override var meleeAttackBonus: Int {
        var attackBonus = self.attributes.strength.bonus + self.equippedWeapon.attack
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
    
    override var rangedAttackBonus: Int {
        var attackBonus = self.attributes.dexterity.bonus + self.equippedWeapon.attack
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
        
    override func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        self.attributes.strength.bonus + (dieRoll == .maximum
            ? self.equippedWeapon.damage.maxValue
            : self.equippedWeapon.damage.randomValue)
    }
    
    override func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        return dieRoll == .maximum
            ? self.equippedWeapon.damage.maxValue
            : self.equippedWeapon.damage.randomValue
    }

    override var armorClass: Int {
        10 + attributes.dexterity.bonus + self.equippedArmor.armorClass + self.equippedShield.armorClass
    }
    
    public init(name: String, race: Race, gender: Gender, role: Role, attributes: Attributes, skills: Skills, entityFactory: EntityFactory) {
        self.race = race
        self.role = role
                
        let equipment = role.defaultEquipment(entityFactory: entityFactory)
        let backpack = role.defaultBackpack(entityFactory: entityFactory)
        
        let hitPoints = HitDie.d6(1, 0).maxValue + attributes.strength.bonus // 1d6 + STR bonus per level, for first level use max health
        super.init(name: name, hitPoints: hitPoints, race: race, gender: gender, attributes: attributes, skills: skills, equipment: equipment, backpack: backpack, entityFactory: entityFactory)
    }

    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.race = .human
        self.role = .fighter

        super.init(json: json, entityFactory: entityFactory)
    }
    
    override func update(state: Game) {
        guard self.isAlive else { return }

        guard let direction = self.direction else { return }

        guard self.sprite.hasActions() == false else { return }
        
        let toCoord = self.coord &+ direction.coord        
        
        if let targetActor = state.activeActors.filter({ $0.coord == toCoord }).first {
            let attack = MeleeAttackAction(actor: self, targetActor: targetActor)
            setAction(attack)
        } else {
            let attackDirections: [Direction] = [.northWest, .northEast, .southWest, .southEast]
            guard attackDirections.contains(direction) == false else { return }
            
            if state.canMove(entity: self, to: toCoord) {
                let move = MoveAction(actor: self, toCoord: toCoord)
                setAction(move)
            } else {
                if let door = state.tiles[Int(toCoord.y)][Int(toCoord.x)] as? Door {
                    let use = UseAction(actor: self, door: door)
                    setAction(use)
                }
            }
        }
    }
    
    func move(direction: Direction) {
        self.direction = direction
    }
    
    func stop() {
        self.direction = nil
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
    
    override func useBackpackItem(at index: Int) {
        if let armor = self.backpackItem(at: index) as? Equippable {
            if self.role.canEquip(armor) == false {
                return
            }
        }
        
        super.useBackpackItem(at: index)
    }
}
