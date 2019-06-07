//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Weapon: Entity {
    let attack: HitDice
    
    required init(json: [String : Any]) {
        let attack = json["AT"] as! String
        self.attack = HitDice(rawValue: attack)!
        
        super.init(json: json)
    }
}
