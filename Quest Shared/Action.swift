//
//  Action.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

private struct AnimationKey {
    static let move = "move"
}

class Action {
    unowned var actor: Actor

    init(actor: Actor) {
        self.actor = actor
    }
    
    func perform() -> Bool {
        fatalError()
    }
}

class MoveAction: Action {
    let coord: int2
    
    init(actor: Actor, coord: int2) {
        self.coord = coord
        super.init(actor: actor)
    }
    
    override func perform() -> Bool {
        guard self.actor.sprite.action(forKey: AnimationKey.move) == nil else {
            return false
        }
        
        print("move")
        
        let position = pointForCoord(self.coord)
        let move = SKAction.sequence([
            SKAction.move(to: position, duration: 0.2),
            SKAction.run {
                self.actor.coord = self.coord
            }
        ])
        self.actor.sprite.run(move, withKey: AnimationKey.move)
        
        return true
    }
}

class IdleAction: Action {
    override func perform() -> Bool {
        print("Idling ...")
        return true
    }
}

