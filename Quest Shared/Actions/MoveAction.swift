//
//  MoveAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

class MoveAction: Action, StatusUpdatable {
    public let path: [vector_int2]
    
    public var toCoord: vector_int2 {
        return self.path.last!
    }
    
    private(set) var message: String?
//    override var message: String {
//        return "[\(self.actor.name)] → \(self.toCoord.x).\(self.toCoord.y)"
//    }    
    
    init(actor: Actor, toCoord: vector_int2) {
        self.path = [toCoord]
        super.init(actor: actor)
    }
    
    init(actor: Actor, coords: [vector_int2]) {
        self.path = coords
        super.init(actor: actor)
    }
    
    override func perform(state: GameState) {
        var energyCost = self.actor.energyCost.move
        
        for effect in self.actor.effects {
            if effect.type == .reduceMovementEnergyCost {
                energyCost -= effect.value
            }
        }
        
        self.actor.energy.drain(max(energyCost, 0))

        self.actor.coord = self.toCoord

        self.message = "\(self.actor.name) moved to \(self.toCoord.x).\(self.toCoord.y)"
    }
}
