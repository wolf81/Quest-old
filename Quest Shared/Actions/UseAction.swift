//
//  InteractAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class InteractAction: Action {    
    unowned let entity: EntityProtocol
    
    init(actor: Actor, entity: EntityProtocol) {
        self.entity = entity
        
        super.init(actor: actor)
    }
    
    override func perform(game: Game) {
        self.actor.energy.drain(50)

        switch entity {
        case let door as Door: door.isOpen = !door.isOpen
        default: fatalError()
        }
    }
}
