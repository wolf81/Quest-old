//
//  TileProtocol.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 15/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

protocol TileProtocol: EntityProtocol {
    init(json: [String: Any], entityFactory: EntityFactory, coord: vector_int2)
}
