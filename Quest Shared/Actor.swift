//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Actor: Entity {
    let hitPoints: Int
    
    let skills: Skills

    var damage: Int = 0
    
    private(set) var attackBonus: Int = 0
    
    private(set) var armorClass: Int = 0
    
    private var action: Action?
        
    var isAlive: Bool {
        return (self.hitPoints - damage) > 0
    }
    
    init(json: [String : Any], hitPoints: Int, armorClass: Int, skills: Skills) {
        self.hitPoints = hitPoints
        self.armorClass = armorClass
        self.skills = skills
        
        super.init(json: json)
    }    
    
    init(name: String, sprite: String, skills: Skills) {
        self.hitPoints = 1
        self.skills = skills
        
        super.init(json: ["name": name, "sprite": "human_male"])
        
        self.sprite.zPosition = 100
    }
    
    required init(json: [String : Any]) {
        self.hitPoints = 1
        self.skills = Skills(physical: 0, subterfuge: 0, knowledge: 0, communication: 0)
        
        super.init(json: json)
        
        self.sprite.zPosition = 100
    }
     
    func getAction(state: Game) -> Action? {
        defer { self.action = nil }
            
        return self.action
    }    
}
