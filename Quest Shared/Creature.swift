//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Creature: Entity {
    private struct AnimationKey {
        static let move = "move"
    }

    required init(json: [String : Any]) {
        super.init(json: json)
        
        self.sprite.zPosition = 100
    }
    
    func move(to position: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        guard self.sprite.action(forKey: AnimationKey.move) == nil else {
            return
        }
        
        let move = SKAction.sequence([
            SKAction.move(to: position, duration: duration),
            SKAction.run(completion)
        ])
        self.sprite.run(move, withKey: AnimationKey.move)
    }
    
    func attack(creature: Creature) {
        
    }
}
