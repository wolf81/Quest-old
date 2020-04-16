//
//  MoveAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

class MoveAction: Action {
    public let path: [vector_int2]
    
    public var toCoord: vector_int2 {
        return self.path.last!
    }
    
    private(set) var duration: TimeInterval = MoveAction.stepDuration
    
    override var message: String {
        return "[\(self.actor.name)] → \(self.toCoord.x).\(self.toCoord.y)"
    }
    
    private static let stepDuration = 1.5
    
    init(actor: Actor, toCoord: vector_int2, timeUnitCost: Int) {
        self.path = [toCoord]
        super.init(actor: actor, timeUnitCost: timeUnitCost)
    }
    
    init(actor: Actor, coords: [vector_int2], timeUnitCost: Int) {
        self.path = coords
        super.init(actor: actor, timeUnitCost: timeUnitCost)
    }
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        guard self.actor.sprite.action(forKey: AnimationKey.move) == nil else {
            return false
        }
        
        defer {
            print("subtract tu: \(self.timeUnitCost)")
            self.actor.subtractTimeUnits(self.timeUnitCost)
            print("tu: \(self.actor.timeUnits)")
        }
                
        self.duration = 0
        var moves: [SKAction] = []
        for coord in self.path {
            let position = GameScene.pointForCoord(coord)
            moves.append(SKAction.move(to: position, duration: MoveAction.stepDuration))
            self.duration += MoveAction.stepDuration
        }
        
        let move = SKAction.sequence([
            SKAction.sequence(moves),
            SKAction.run {
                self.actor.coord = self.toCoord
                completion()
            }
        ])
        self.actor.sprite.run(move, withKey: AnimationKey.move)
        
        return true
    }
}
