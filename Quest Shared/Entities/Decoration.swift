//
//  Decoration.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 28/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import simd

class Decoration: Entity, TileProtocol {
    var didExplore: Bool = false

    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        super.init(json: json, entityFactory: entityFactory)
        
        self.coord = coord
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        super.init(json: json, entityFactory: entityFactory)
    }
}
