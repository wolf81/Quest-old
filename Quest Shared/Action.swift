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
    
    func perform(completion: @escaping () -> Void) -> Bool {
        fatalError()
    }
}

class MoveAction: Action {
    public let toCoord: vector_int2
    
    public let duration: TimeInterval = 0.15
    
    init(actor: Actor, toCoord: vector_int2) {
        self.toCoord = toCoord
        super.init(actor: actor)
    }
    
    init(actor: Actor, coords: [vector_int2]) {
        self.toCoord = coords.last!
        super.init(actor: actor)
    }
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        guard self.actor.sprite.action(forKey: AnimationKey.move) == nil else {
            return false
        }
        
        print("\(self.actor.name) moves to \(self.toCoord.x).\(self.toCoord.y)")
        
        let position = GameScene.pointForCoord(self.toCoord)
        let move = SKAction.sequence([
            SKAction.move(to: position, duration: self.duration),
            SKAction.run {
                self.actor.coord = self.toCoord
                completion()
            }
        ])
        self.actor.sprite.run(move, withKey: AnimationKey.move)
        
        return true
    }
}

class AttackAction: Action {
    public let targetActor: Actor
    
    init(actor: Actor, targetActor: Actor) {
        self.targetActor = targetActor
        super.init(actor: actor)
    }
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        print("\(self.actor.name) (HP \(self.actor.hitPoints.current) / \(self.actor.hitPoints.base)) attacks \(self.targetActor.name) (HP \(self.targetActor.hitPoints.current) / \(self.targetActor.hitPoints.base))")

        let attackRoll = HitDie.d20(1, 0).randomValue + self.actor.attackBonus
        let armorClass = targetActor.armorClass
        print("attack roll: \(attackRoll) vs \(armorClass)")
        if attackRoll - armorClass > 0 {
            let damage = self.actor.attackDamage()
            print("hit for \(damage) damage")
            self.targetActor.hitPoints.remove(hitPoints: damage)            
        }
        else {
            print("miss")
        }
        
        completion()
        
        return true
    }
}

class IdleAction: Action {
    override func perform(completion: @escaping () -> Void) -> Bool {
        print("\(self.actor) is idle")

        completion()
        
        return true
    }
}

