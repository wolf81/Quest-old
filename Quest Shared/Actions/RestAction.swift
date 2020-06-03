//
//  RestAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 30/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import simd

enum RestState {
    case started
    case progress
    case completed
}

class RestAction: Action, StatusUpdatable {
    private(set) var message: String?
    
    private(set) var state: RestState = .progress
    
    override func perform(state: GameState) {
        self.actor.energy.drain(50)
        
        if self.actor.isResting == false {
            self.state = .started
            let sleep = try! state.entityFactory.newEntity(type: Effect.self, name: "Sleep")
            self.actor.applyEffect(effect: sleep)
            self.actor.updateVisibility()
            return
        }
        
        let hitpointGain = 1
        self.actor.hitPoints.restore(hitPoints: hitpointGain)
        self.message = "\(self.actor.name) recovering hitpoints ..."

        let didEncounterMonster = arc4random_uniform(5) == 0
        let didRestoreFullHealth = self.actor.hitPoints.current == self.actor.hitPoints.base
        if didEncounterMonster || didRestoreFullHealth {
            self.actor.removeEffect(named: "Sleep")
            self.actor.updateVisibility()
            self.state = .completed
        }

        if didEncounterMonster {
            while true {
                let coord = self.actor.visibleCoords.randomElement()!
                let node = state.getMapNodeType(at: coord)
                if node == .open && coord != state.hero.coord {
                    let monster = state.spawnMonster(at: coord)
                    monster.energy.drain(30) // monster starts at -30
                    monster.updateVisibility()
                    monster.update(state: state, deltaTime: 0)
                    self.message = "Your rest was interrupted by an angry \(monster.name)"
                    break
                }
            }
        }
    }
}
