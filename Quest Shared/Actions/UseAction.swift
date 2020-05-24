//
//  UseAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class UseAction: Action {
    unowned let door: Door
    
    init(actor: Actor, door: Door) {
        self.door = door
        
        super.init(actor: actor)
    }
    
    override func perform(game: Game) {
        self.door.isOpen = !self.door.isOpen

        self.actor.energy.drain(50)
    }
}
