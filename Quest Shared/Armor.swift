//
//  Armor.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class Armor: Entity {
    let armorClass: Int
    
    required init(json: [String : Any]) {
        let armorClass = json["AC"] as! Int
        self.armorClass = armorClass
        
        super.init(json: json)
    }
    
    static var none: Armor {
        get {
            return self.init(json: ["AC": 0])
        }
    }
}
