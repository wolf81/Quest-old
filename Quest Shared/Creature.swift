//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Creature: Entity {
    let hitPoints: Int
    
    var damage: Int = 0
    
    var isAlive: Bool {
        return (self.hitPoints - damage) > 0
    }
    
    private struct AnimationKey {
        static let move = "move"
    }

    init(json: [String : Any], hitPoints: Int) {
        self.hitPoints = hitPoints
        
        super.init(json: json)
    }
    
    required init(json: [String : Any]) {
        self.hitPoints = 1
        
        super.init(json: json)
        
        self.sprite.zPosition = 100
    }
    
    func defend(hit: Int, damage: Int) {
        fatalError()
    }
    
    private func attack(creature: Creature, completion: @escaping () -> Void) {
        creature.defend(hit: 5, damage: 2)
        
        completion()
    }
    
    private func move(to position: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        guard self.sprite.action(forKey: AnimationKey.move) == nil else {
            return
        }
        
        let move = SKAction.sequence([
            SKAction.move(to: position, duration: duration),
            SKAction.run(completion)
        ])
        self.sprite.run(move, withKey: AnimationKey.move)
    }
}

protocol ActionDelegate {
    func entity(_ entity: Entity, didPerformAction action: Action)
}

extension Creature : Actionable {
    func perform(action: Action, delegate: ActionDelegate) {
        switch action {
        case .attack(let creature):
            attack(creature: creature) {
                delegate.entity(self, didPerformAction: action)
            }
        case .move(let coord):
            move(to: pointForCoord(coord), duration: 0.2) {
                self.coord = coord
                delegate.entity(self, didPerformAction: action)
            }
        }
    }
}
