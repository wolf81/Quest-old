//
//  HitDie.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

enum HitDie : RawRepresentable, CustomStringConvertible {
    case d3(Int, Int)
    case d4(Int, Int)
    case d6(Int, Int)
    case d8(Int, Int)
    case d10(Int, Int)
    case d12(Int, Int)
    case d20(Int, Int)
    
    var dieCount: Int {
        get {
            switch self {
            case .d3(let dieCount, _): return dieCount
            case .d4(let dieCount, _): return dieCount
            case .d6(let dieCount, _): return dieCount
            case .d8(let dieCount, _): return dieCount
            case .d10(let dieCount, _): return dieCount
            case .d12(let dieCount, _): return dieCount
            case .d20(let dieCount, _): return dieCount
            }
        }
    }
    
    var minValue: Int {
        switch self {
        case .d3(let dieCount, let bonus): return dieCount + bonus
        case .d4(let dieCount, let bonus): return dieCount + bonus
        case .d6(let dieCount, let bonus): return dieCount + bonus
        case .d8(let dieCount, let bonus): return dieCount + bonus
        case .d10(let dieCount, let bonus): return dieCount + bonus
        case .d12(let dieCount, let bonus): return dieCount + bonus
        case .d20(let dieCount, let bonus): return dieCount + bonus
        }
    }

    var maxValue: Int {
        switch self {
        case .d3(let dieCount, let bonus): return 4 * dieCount + bonus
        case .d4(let dieCount, let bonus): return 4 * dieCount + bonus
        case .d6(let dieCount, let bonus): return 6 * dieCount + bonus
        case .d8(let dieCount, let bonus): return 8 * dieCount + bonus
        case .d10(let dieCount, let bonus): return 10 * dieCount + bonus
        case .d12(let dieCount, let bonus): return 12 * dieCount + bonus
        case .d20(let dieCount, let bonus): return 20 * dieCount + bonus
        }
    }    
    
    var valueRange: ClosedRange<Int> {
        return self.minValue ... self.maxValue
    }
    
    var randomValue: Int {
        return Int(arc4random_uniform(UInt32(self.valueRange.count)) + UInt32(self.minValue))
    }

    var rawValue: String {
        var description = ""
        switch self {
        case .d3(let dieCount, let bonus): description = "\(dieCount)d4+\(bonus)"
        case .d4(let dieCount, let bonus): description = "\(dieCount)d4+\(bonus)"
        case .d6(let dieCount, let bonus): description = "\(dieCount)d6+\(bonus)"
        case .d8(let dieCount, let bonus): description = "\(dieCount)d8+\(bonus)"
        case .d10(let dieCount, let bonus): description = "\(dieCount)d10+\(bonus)"
        case .d12(let dieCount, let bonus): description = "\(dieCount)d12+\(bonus)"
        case .d20(let dieCount, let bonus): description = "\(dieCount)d20+\(bonus)"
        }
        
        if description.hasSuffix("+0") {
            description.removeLast(2)
        }
        
        return description
    }
    
    init?(rawValue: String) {
        var bonus = 0
        
        var strings = rawValue.split(separator: "+")
        let dieString = strings.first!
        
        if strings.count > 1, let bonusString = strings.last {
            bonus = Int(bonusString) ?? 0
        }
        
        strings = dieString.split(separator: "d")
        
        guard let dieCount = Int(strings.first!), let dieValue = Int(strings.last!) else { return nil }
        
        switch dieValue {
        case 3: self = HitDie.d3(dieCount, bonus)
        case 4: self = HitDie.d4(dieCount, bonus)
        case 6: self = HitDie.d6(dieCount, bonus)
        case 8: self = HitDie.d8(dieCount, bonus)
        case 10: self = HitDie.d10(dieCount, bonus)
        case 12: self = HitDie.d12(dieCount, bonus)
        case 20: self = HitDie.d20(dieCount, bonus)
        default:
            fatalError("unknown die value \(dieValue)")
        }
    }
    
    var description: String {
        return self.rawValue
    }
}
