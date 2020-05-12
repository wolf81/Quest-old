//
//  Lootable.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

protocol Lootable: Entity {
    var sprite: SKSpriteNode { get }
    
    var name: String { get }
}
