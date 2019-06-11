//
//  RandomNumberGenerator.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation
import GameplayKit

class RandomNumberGenerator: NumberGeneratable {
    private var distribution: GKRandomDistribution

    init() {
        self.distribution = GKRandomDistribution(
            randomSource: GKARC4RandomSource(),
            lowestValue: 0,
            highestValue: 1_000_000
        )
    }
    
    func seed(data: Data) {
        self.distribution = GKRandomDistribution(
            randomSource: GKARC4RandomSource(seed: data),
            lowestValue: 0,
            highestValue: 1_000_000
        )
    }
    
    func next(maxValue: Int) -> Int {
        return Int(self.distribution.nextUniform() * Float(maxValue))
    }
}
