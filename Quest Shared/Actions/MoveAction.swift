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
        
    private(set) var triggeredTrap: (Trap, Int)? = nil
    
    init(actor: Actor, toCoord: vector_int2) {
        self.path = [toCoord]
        super.init(actor: actor)
    }
    
    init(actor: Actor, coords: [vector_int2]) {
        self.path = coords
        super.init(actor: actor)
    }
    
    override func perform(state: GameState) -> Bool {
        var energyCost = self.actor.energyCost.move
        
        for effect in self.actor.effects {
            if effect.type == .lowerMovementEnergyCost {
                energyCost -= effect.value
            }            
            if effect.type == .raiseMovementEnergyCost {
                energyCost += effect.value
            }
        }
        
        self.actor.energy.drain(energyCost)
             
        if self.actor is Monster {
            guard self.actor.canSpot(actor: state.hero) else { return false }
        }
        
        self.actor.coord = self.toCoord
        
        if let hero = self.actor as? Hero, hero.isSearching {
            for coord in hero.visibleCoords {
                guard Functions.distanceBetween(hero.coord, coord) <= 2, coord != hero.coord else { continue }

                if let trap = state.getTrap(at: coord), trap.isActive {
                    if trap.search(hero: hero) {
                        print("trap discovered @ \(coord.x).\(coord.y)")
                    } else {
                        print("trap stays hidden")
                    }
                }
            }
        }

        if let trap = state.getTrap(at: self.toCoord), trap.isActive, let hero = self.actor as? Hero {
            let damage = trap.trigger(actor: hero)
            self.triggeredTrap = (trap, damage)
            self.message = "\(self.actor.name) triggered trap at \(self.toCoord.x).\(self.toCoord.y): \((damage == 0) ? "trap missed" : "trap dealt \(damage) damage")"
        } else {
            self.message = "\(self.actor.name) moved to \(self.toCoord.x).\(self.toCoord.y)"
        }
        
        return true
    }
}
