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
    let equipment: Equipment
    let race: Race
    let role: Role
    let level: Int = 1
    
    private var direction: Direction?

    override var attackBonus: Int {
        var attackBonus = self.attributes.strength.bonus
        if self.role == .fighter {
            attackBonus += 1
            attackBonus += self.level % 5
        }
        return attackBonus
    }
    
    override var armorClass: Int { return 10 + attributes.dexterity.bonus + self.equipment.armor.armorClass /* + armor bonus */ }
    
    public init(name: String, race: Race, role: Role, attributes: Attributes, skills: Skills, equipment: Equipment) {
        self.race = race
        self.role = role
        self.attributes = attributes
        self.equipment = equipment
        
        super.init(name: name, sprite: "human_male", skills: skills)
    }
    
    required init(json: [String : Any]) {
        self.attributes = Attributes()
        self.race = .human
        self.role = .fighter
        self.equipment = Equipment()
        
        super.init(json: json)
    
        sprite.zPosition = 1000
    }
    
    func move(direction: Direction) {
        self.direction = direction
    }
    
    var description: String {
        return "\(self.race) \(self.role) [ HP: \(self.hitPoints - self.damage) / STR: \(self.attributes.strength) / DEX: \(self.attributes.dexterity) / MIND: \(self.attributes.mind) ]"
    }
    
    override func getAction(state: Game) -> Action? {
        guard let direction = self.direction else { return nil }
        
        defer {
            self.direction = nil
        }
        
        let toCoord = self.coord &+ direction.coord            
        
        if let targetActor = state.getActorAt(coord: toCoord) {
            return AttackAction(actor: self, targetActor: targetActor)
        }
        
        if state.canMoveEntity(entity: self, toCoord: toCoord) {
            return MoveAction(actor: self, toCoord: toCoord)
        }
                
        return nil
    }    
}
