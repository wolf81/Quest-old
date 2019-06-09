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
    
    func perform() {
        fatalError()
    }
}

class MoveAction: Action {
    let coord: int2
    
    init(actor: Actor, coord: int2) {
        self.coord = coord
        super.init(actor: actor)
    }
    
    override func perform() {
        let position = pointForCoord(self.coord)
        self.move(to: position, duration: 0.2) {
            self.actor.coord = self.coord
            print("finished move")
        }
    }
    
    private func move(to position: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        guard self.actor.sprite.action(forKey: AnimationKey.move) == nil else {
            return
        }
        
        let move = SKAction.sequence([
            SKAction.move(to: position, duration: duration),
            SKAction.run(completion)
        ])
        self.actor.sprite.run(move, withKey: AnimationKey.move)
    }
}

class IdleAction: Action {
    override func perform() {
        print("Idling ...")
    }
}

