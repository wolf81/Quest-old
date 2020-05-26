//
//  DeadEndRemoval.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum DeadEndRemoval: String {
    case none
    case some
    case all
    
    var percentage: Int {
        switch self {
        case .none: return 0
        case .some: return 50
        case .all: return 100
        }
    }
}
