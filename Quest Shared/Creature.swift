//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum HitDice : RawRepresentable, CustomStringConvertible {
    var rawValue: String {
        return ""
    }
    
    case d4(Int, Int)
    case d6(Int, Int)
    case d8(Int, Int)
    
    init?(rawValue: String) {
        var bonus = 0

        var strings = rawValue.split(separator: "+")
        let diceString = strings.first!

        if strings.count > 1, let bonusString = strings.last {
            bonus = Int(bonusString) ?? 0
        }
        
        strings = diceString.split(separator: "d")

        guard let diceCount = Int(strings.first!), let diceValue = Int(strings.last!) else { return nil }
        
        switch diceValue {
        case 4: self = HitDice.d4(diceCount, bonus)
        case 6: self = HitDice.d6(diceCount, bonus)
        case 8: self = HitDice.d8(diceCount, bonus)
        default:
            fatalError("unknown dice value \(diceValue)")
        }
    }
    
    var description: String {
        var description = ""
        switch self {
        case .d4(let diceCount, let bonus): description = "\(diceCount)d4+\(bonus)"
        case .d6(let diceCount, let bonus): description = "\(diceCount)d6+\(bonus)"
        case .d8(let diceCount, let bonus): description = "\(diceCount)d8+\(bonus)"
        }
        if description.hasSuffix("+0") {
            description.removeLast(2)
        }
        return description
    }
}

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
