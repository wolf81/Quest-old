//
//  Sill.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 06/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

struct Sill {
    var r: Int
    var c: Int
    var direction: Direction
    var door_r: Int
    var door_c: Int
    var out_id: UInt?
    
    init(r: Int, c: Int, direction: Direction, door_r: Int, door_c: Int, out_id: UInt?) {
        self.r = r
        self.c = c
        self.direction = direction
        self.door_r = door_r
        self.door_c = door_c
        self.out_id = out_id
    }
}
