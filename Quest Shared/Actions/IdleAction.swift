//
//  IdleAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class IdleAction: Action {
//    override var message: String {
//        return "[\(self.actor.name)] ⦰ \(self.actor.coord.x).\(self.actor.coord.y)"
//    }
    
    override func perform(game: Game) {
        self.actor.drainEnergy()
    }
}
