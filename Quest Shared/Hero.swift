//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum Attribute {
    case strength(Int)
    case dexterity(Int)
    case mind(Int)
    
    var bonus: Int {
        switch self {
        case .dexterity(let value): return (value - 10) / 2
        case .mind(let value): return (value - 10) / 2
        case .strength(let value): return (value - 10) / 2
        }
    }
}

class Hero: Actor, CustomStringConvertible {
    var attributes: [Attribute]

    private var direction: Direction?

    init(json: [String : Any], attributes: [Attribute]) {
        self.attributes = attributes
        
        super.init(json: json)

        sprite.zPosition = 1000
    }

    required init(json: [String : Any]) {
        self.attributes = []
        
        super.init(json: json)
    
        sprite.zPosition = 1000
    }
    
    func move(direction: Direction) {
        self.direction = direction
    }
    
    var description: String {
        return "Hero [ HP: \(self.hitPoints - self.damage) ]"
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
