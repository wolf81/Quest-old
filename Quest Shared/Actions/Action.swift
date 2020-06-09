//
//  Action.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Action {
    unowned var actor: Actor
    
    init(actor: Actor) {
        self.actor = actor
    }
    
    func perform(state: GameState) -> Bool {
        fatalError()
    }
}


