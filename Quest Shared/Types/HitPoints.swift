//
//  HitPoints.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

struct HitPoints: CustomStringConvertible {
    private(set) var base: Int
    private var lost: Int
    
    var current: Int { return self.base - self.lost }
        
    init(base: Int) {
        self.base = base
        self.lost = 0
    }
    
    mutating func remove(hitPoints: Int) {
        self.lost += hitPoints
    }
    
    var description: String {
        return "HP: \(self.current) / \(self.base)"
    }
}
