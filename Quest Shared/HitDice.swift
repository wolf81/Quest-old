//
//  HitDice.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

enum HitDice : RawRepresentable, CustomStringConvertible {
    case d4(Int, Int)
    case d6(Int, Int)
    case d8(Int, Int)
    case d10(Int, Int)
    case d12(Int, Int)
    
    var minValue: Int {
        switch self {
        case .d4(let diceCount, let bonus): return diceCount + bonus
        case .d6(let diceCount, let bonus): return diceCount + bonus
        case .d8(let diceCount, let bonus): return diceCount + bonus
        case .d10(let diceCount, let bonus): return diceCount + bonus
        case .d12(let diceCount, let bonus): return diceCount + bonus
        }
    }

    var maxValue: Int {
        switch self {
        case .d4(let diceCount, let bonus): return 4 * diceCount + bonus
        case .d6(let diceCount, let bonus): return 6 * diceCount + bonus
        case .d8(let diceCount, let bonus): return 8 * diceCount + bonus
        case .d10(let diceCount, let bonus): return 10 * diceCount + bonus
        case .d12(let diceCount, let bonus): return 12 * diceCount + bonus
        }
    }

    var rawValue: String {
        var description = ""
        switch self {
        case .d4(let diceCount, let bonus): description = "\(diceCount)d4+\(bonus)"
        case .d6(let diceCount, let bonus): description = "\(diceCount)d6+\(bonus)"
        case .d8(let diceCount, let bonus): description = "\(diceCount)d8+\(bonus)"
        case .d10(let diceCount, let bonus): description = "\(diceCount)d10+\(bonus)"
        case .d12(let diceCount, let bonus): description = "\(diceCount)d12+\(bonus)"
        }
        
        if description.hasSuffix("+0") {
            description.removeLast(2)
        }
        
        return description
    }
    
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
        case 10: self = HitDice.d10(diceCount, bonus)
        case 12: self = HitDice.d12(diceCount, bonus)
        default:
            fatalError("unknown dice value \(diceValue)")
        }
    }
    
    var description: String {
        return self.rawValue
    }
}