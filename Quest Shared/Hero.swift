//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

struct Attributes {
    let strength: Attribute
    let dexterity: Attribute
    let mind: Attribute
    
    public init() {
        self.strength = .average
        self.dexterity = .average
        self.mind = .average
    }
    
    public init(strength: Attribute, dexterity: Attribute, mind: Attribute) {
        self.strength = strength
        self.dexterity = dexterity
        self.mind = mind
    }
}

class Hero: Actor, CustomStringConvertible {
    let attributes: Attributes
    let race: Race
    let role: Role
    
    private var direction: Direction?

    override var attackBonus: Int {
        return self.attributes.strength.bonus
    }
    
    public init(name: String, race: Race, role: Role, attributes: Attributes) {
        self.race = race
        self.role = role
        self.attributes = attributes
        
        super.init(json: ["name": name, "sprite": "human_male"])
    }
    
    required init(json: [String : Any]) {
        self.attributes = Attributes()
        self.race = .human
        self.role = .fighter
        
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
