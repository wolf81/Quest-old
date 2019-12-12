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

    override var attackBonus: Int {
        var attackBonus = self.attributes.strength.bonus + self.equipment.weapon.attack
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
        
    override func attackDamage() -> Int { self.attributes.strength.bonus + self.equipment.weapon.damage.randomValue }
    
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
            self.direction = nil
            self.path = nil
        }

        if let direction = self.direction {
            let toCoord = self.coord &+ direction.coord
            
            if let targetActor = state.getActorAt(coord: toCoord) {
                return AttackAction(actor: self, targetActor: targetActor)
            }
            
            if state.canMove(entity: self, toCoord: toCoord) {
                return MoveAction(actor: self, toCoord: toCoord)
            }
        } else if let path = self.path {
            return MoveAction(actor: self, coords: path)
//            if state.canMove(entity: self, toCoord: toCoord) {
//                return MoveAction(actor: self, toCoord: toCoord)
//            }
        }
                            
        return nil
    }    
}
