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
    static var average: Attribute {
        return Attribute(12)
    }
    
    var bonus: Int {
        return (self - 10) / 2
    }
}

struct Attributes {
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
}
