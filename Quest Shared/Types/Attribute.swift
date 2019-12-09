//
//  Attribute.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

typealias Attribute = Int

extension Attribute {
    static var average: Attribute { return Attribute(12) }
    
    var bonus: Int { return (self - 10) / 2 }
    
    static func roll() -> Attribute {
        var hitDies: [Int] = [HitDie.d6(1, 0).randomValue, HitDie.d6(1, 0).randomValue, HitDie.d6(1, 0).randomValue, HitDie.d6(1, 0).randomValue].sorted(by: { $0 > $1 })
        hitDies.removeLast()
        return hitDies.reduce(0, { $0 + $1 })
    }
}

struct Attributes: CustomStringConvertible {
    let strength: Attribute
    let dexterity: Attribute
    let mind: Attribute
    
    public init() {
        self.strength = .average
        self.dexterity = .average
        self.mind = .average
    }
    
    public init(strength: Attribute, dexterity: Attribute, mind: Attribute) {
        self.strength = strength
        self.dexterity = dexterity
        self.mind = mind
    }
    
    var description: String {
        return "STR: \(self.strength), DEX: \(self.dexterity), MIND: \(self.mind)"
    }
    
    public static func roll(race: Race) -> Attributes {
        let strength = Attribute.roll() + (race == .dwarf ? 2 : 0)
        let dexterity = Attribute.roll() + (race == .halfling ? 2 : 0)
        let mind = Attribute.roll() + (race == .elf ? 2 : 0)
        return Attributes(strength: strength, dexterity: dexterity, mind: mind)
    }
}
