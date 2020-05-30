//
//  HitPoints.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

protocol HitPointsDelegate: class {
    func hitPointsChanged(current: Int, total: Int)
}

struct HitPoints: CustomStringConvertible {
    private(set) var base: Int
    private(set) var lost: Int
    
    var current: Int { return self.base - self.lost }
        
    weak var delegate: HitPointsDelegate?
    
    init(base: Int) {
        self.base = base
        self.lost = 0
    }
    
    mutating func remove(_ hitPoints: Int) {
        self.lost += hitPoints
        
        self.delegate?.hitPointsChanged(current: max(self.current, 0), total: self.base)
    }
    
    mutating func restore(hitPoints: Int) {
        self.lost -= (hitPoints > self.lost) ? self.lost : hitPoints
        
        self.delegate?.hitPointsChanged(current: max(self.current, 0), total: self.base)
    }
    
    var description: String {
        return "HP: \(self.current) / \(self.base)"
    }
}
