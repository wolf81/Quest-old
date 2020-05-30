//
//  HitType.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 30/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

enum HitState {
    case criticalMiss
    case miss
    case hit
    case criticalHit
    
    var isHit: Bool { [HitState.hit, HitState.criticalHit].contains(self) }
}
