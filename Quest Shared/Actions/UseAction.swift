//
//  InteractAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class InteractAction: Action {    
    unowned let interactable: Interactable
    
    init(actor: Actor, interactable: Interactable) {
        self.interactable = interactable
        
        super.init(actor: actor)
    }
    
    override func perform(state: GameState) -> Bool {
        self.actor.energy.drain(50)

        self.interactable.interact(state: state)

        return true
    }
}
