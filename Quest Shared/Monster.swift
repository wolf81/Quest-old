//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class Monster: Entity {
    required init(json: [String : Any]) {
        super.init(json: json)
        
        self.sprite.zPosition = 100
    }
}
