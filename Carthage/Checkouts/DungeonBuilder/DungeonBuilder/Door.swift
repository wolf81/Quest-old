//
//  Door.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 07/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

public struct Door {
    public var coord: vector_int2 { return vector_int2(Int32(self.row), Int32(self.col)) }
    
    var row: Int
    var col: Int
//    var key: String
//    var type: String
    var out_id: UInt?
    
    init(row: Int, col: Int, out_id: UInt?) {
        self.row = row
        self.col = col
        self.out_id = out_id
    }
}
