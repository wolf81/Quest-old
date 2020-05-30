//
//  RestAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 30/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class RestAction: Action {
    var finished: Bool { self.actor.hitPoints.lost == 0 }
    
    override func perform(state: GameState) {
        self.actor.energy.drain(50)

        self.actor.hitPoints.restore(hitPoints: 1)
        
        if self.actor.hitPoints.current == self.actor.hitPoints.base {
            self.actor.isResting = false
        }        
    }
}
