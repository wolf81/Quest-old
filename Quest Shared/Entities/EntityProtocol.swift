//
//  EntityProtocol.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 15/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

protocol EntityProtocol: JSONConstructable {
    var name: String { get }
    
    var sprite: SKSpriteNode { get }
    
    var coord: vector_int2 { get }
    
    func copy(coord: vector_int2) -> Self
}
