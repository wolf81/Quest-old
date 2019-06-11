//
//  Position.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 05/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

struct Position {
    var i: Int
    var j: Int
    
    static var zero: Position {
        return Position(i: 0, j: 0)
    }
    
    init(i: Int, j: Int) {
        self.i = i
        self.j = j
    }
}
