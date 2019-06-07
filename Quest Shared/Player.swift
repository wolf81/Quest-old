//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Player: Entity {
    required init(json: [String : Any]) {
        super.init(json: json)
        
        sprite.zPosition = 100
    }
}
