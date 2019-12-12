//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Actor: Entity {
    var hitPoints: HitPoints

    var isAlive: Bool { return self.hitPoints.current > 0 }

    private(set) var skills: Skills
    
    private(set) var equipment: Equipment
    
    private(set) var attackBonus: Int = 0
    
    private(set) var armorClass: Int = 0
    
    private(set) var speed: Int = 1
    
    private(set) var sight: Int = 12
    
    private var action: Action?
            
    init(json: [String : Any], hitPoints: Int, armorClass: Int, skills: Skills, equipment: Equipment) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.armorClass = armorClass
        self.skills = skills
        self.equipment = equipment
        
        self.speed = json["speed"] as? Int ?? 1
        self.sight = json["sight"] as? Int ?? 12
        
        super.init(json: json)
    }    
    
    init(name: String, hitPoints: Int, race: Race, gender: Gender, skills: Skills, equipment: Equipment) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.skills = skills
        self.equipment = equipment
        
        super.init(json: ["name": name, "sprite": "\(race)_\(gender)"])
        
        self.sprite.zPosition = 100
    }
    
    required init(json: [String : Any]) {
        self.hitPoints = HitPoints(base: 1)
        self.skills = Skills(physical: 0, subterfuge: 0, knowledge: 0, communication: 0)
        self.equipment = Equipment.none
    
        super.init(json: json)
        
        self.sprite.zPosition = 100
    }
    
    func attackDamage() -> Int { return self.equipment.weapon.damage.randomValue }
     
    func getAction(state: Game) -> Action? {
        defer { self.action = nil }
        
        return self.action
    }    
}
