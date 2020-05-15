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
    
    private(set) var timeUnitCost: Int = Constants.timeUnitsPerTurn

    init(actor: Actor, timeUnitCost: Int) {
        self.actor = actor
        self.timeUnitCost = timeUnitCost
    }
    
    func perform(game: Game, completion: @escaping () -> Void) -> Bool {
        fatalError()
    }
}


