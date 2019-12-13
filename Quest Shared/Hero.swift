//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Hero: Actor, CustomStringConvertible {
    let attributes: Attributes
    let race: Race
    let role: Role
    let level: Int = 1
    
    override var speed: Int { return 4 }
    
    private var direction: Direction?
        
    private var path: [vector_int2]?
    
    private var meleeTarget: Actor?
    
    private var rangedTarget: Actor?

    override var meleeAttackBonus: Int {
        var attackBonus = self.attributes.strength.bonus + self.equipment.meleeWeapon.attack
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
    
    override var rangedAttackBonus: Int {
        var attackBonus = self.attributes.dexterity.bonus + self.equipment.rangedWeapon.attack
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
        
    override func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        return self.attributes.strength.bonus + (dieRoll == .maximum ? self.equipment.meleeWeapon.damage.maxValue : self.equipment.meleeWeapon.damage.randomValue)
    }
    
    override func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        return dieRoll == .maximum ? self.equipment.rangedWeapon.damage.maxValue : self.equipment.rangedWeapon.damage.randomValue
    }

    override var armorClass: Int { return 10 + attributes.dexterity.bonus + self.equipment.armor.armorClass + self.equipment.shield.armorClass }
    
    public init(name: String, race: Race, gender: Gender, role: Role, attributes: Attributes, skills: Skills, equipment: Equipment) {
        self.race = race
        self.role = role
        self.attributes = attributes
        
        let hitPoints = HitDie.d6(1, 0).maxValue + attributes.strength.bonus // 1d6 + STR bonus per level, for first level use max health
        super.init(name: name, hitPoints: hitPoints, race: race, gender: gender, skills: skills, equipment: equipment)
    }
    
    required init(json: [String : Any]) {
        self.attributes = Attributes()
        self.race = .human
        self.role = .fighter
        
        super.init(json: json)
    
        sprite.zPosition = 1000
    }
    
    func move(path: [vector_int2]) {
        self.path = path
    }
    
    func move(direction: Direction) {
        self.direction = direction
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
        """
    }
    
    override func getAction(state: Game) -> Action? {
        defer {
            self.path = nil
            self.direction = nil
            self.meleeTarget = nil
            self.rangedTarget = nil
        }

        if self.isAlive == false {
            return DieAction(actor: self)
        }
        
        if let direction = self.direction {
            let toCoord = self.coord &+ direction.coord
            
            if let targetActor = state.getActorAt(coord: toCoord) {                
                return MeleeAttackAction(actor: self, targetActor: targetActor)
            }
            
            if state.canMove(entity: self, toCoord: toCoord) {
                return MoveAction(actor: self, toCoord: toCoord)
            }
        } else if let path = self.path {
            return MoveAction(actor: self, coords: path)
        } else if let meleeTarget = self.meleeTarget {
            return MeleeAttackAction(actor: self, targetActor: meleeTarget)
        } else if let rangedTarget = self.rangedTarget {
            return RangedAttackAction(actor: self, targetActor: rangedTarget)
        }
                             
        return nil
    }    
}
