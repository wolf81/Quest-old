//
//  Map.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 27/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import simd

typealias Map = [[NodeType]]

extension Map {
    subscript(coord: vector_int2) -> NodeType {
        return self[Int(coord.y)][Int(coord.x)]
    }
}
