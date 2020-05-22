//
//  DieAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class DieAction: Action, StatusUpdatable {
    var message: String? { "\(self.actor.name) died" }
        
    override func perform(game: Game) {
        self.actor.energy.drain()
    }
}
