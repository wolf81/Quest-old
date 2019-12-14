//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum DieRoll {
    case random
    case maximum
}

class Actor: Entity {
    var hitPoints: HitPoints

    var isAlive: Bool { return self.hitPoints.current > 0 }

    private(set) var skills: Skills
    
    private(set) var equipment: Equipment
    
    private(set) var attributes: Attributes = Attributes(strength: 12, dexterity: 12, mind: 12)

    private(set) var meleeAttackBonus: Int = 0

    private(set) var rangedAttackBonus: Int = 0

    private(set) var armorClass: Int = 0
    
    private(set) var speed: Int = 1
    
    private(set) var sight: Int = 12
    
    private(set) var level: Int = 1
    
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
    
    init(name: String, hitPoints: Int, race: Race, gender: Gender, attributes: Attributes, skills: Skills, equipment: Equipment) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.skills = skills
        self.equipment = equipment
        self.attributes = attributes
        
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
    
    func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        return dieRoll == .maximum ? self.equipment.meleeWeapon.damage.maxValue : self.equipment.meleeWeapon.damage.randomValue
    }

    func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        return dieRoll == .maximum ? self.equipment.rangedWeapon.damage.maxValue : self.equipment.rangedWeapon.damage.randomValue
    }

    func getAction(state: Game) -> Action? {
        defer { self.action = nil }
        
        return self.action
    }    
}
