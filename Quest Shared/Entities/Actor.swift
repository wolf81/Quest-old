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

    private(set) var actionCost: ActionCost = ActionCost()
    
    private(set) var meleeAttackBonus: Int = 0

    private(set) var rangedAttackBonus: Int = 0

    private(set) var armorClass: Int = 0
        
    private(set) var sight: Int32 = 4
    
    private(set) var level: Int = 1
    
    private(set) var timeUnits: Int = 0
    
    private(set) var healthBar: HealthBar!
                
    init(json: [String : Any], hitPoints: Int, armorClass: Int, skills: Skills, equipment: Equipment) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.armorClass = armorClass
        self.skills = skills
        self.equipment = equipment
        
        self.sight = json["sight"] as? Int32 ?? 6

        let actionCostJson = json["actionCost"] as? [String: Int] ?? [:]
        self.actionCost = ActionCost(json: actionCostJson)

        super.init(json: json)
                
        self.sprite.addChild(equipment.meleeWeapon.sprite)
        
        self.hitPoints.delegate = self

        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
    }    
    
    init(name: String, hitPoints: Int, race: Race, gender: Gender, attributes: Attributes, skills: Skills, equipment: Equipment) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.skills = skills
        self.equipment = equipment
        self.attributes = attributes
        
        super.init(json: ["name": name, "sprite": "\(race)_\(gender)"])

        self.sprite.addChild(equipment.armor.sprite)
        self.sprite.addChild(equipment.meleeWeapon.sprite)
        self.sprite.addChild(equipment.shield.sprite)

        self.hitPoints.delegate = self

        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
    }
    
    required init(json: [String : Any]) {
        self.hitPoints = HitPoints(base: 1)
        self.skills = Skills(physical: 0, subterfuge: 0, knowledge: 0, communication: 0)
        self.equipment = Equipment.none
    
        super.init(json: json)

        self.hitPoints.delegate = self

        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
    }
    
    func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        return dieRoll == .maximum ? self.equipment.meleeWeapon.damage.maxValue : self.equipment.meleeWeapon.damage.randomValue
    }

    func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        return dieRoll == .maximum ? self.equipment.rangedWeapon.damage.maxValue : self.equipment.rangedWeapon.damage.randomValue
    }
    
    func addTimeUnits(_ timeUnits: Int) {
        self.timeUnits = min(self.timeUnits + timeUnits, Constants.timeUnitsPerTurn * 2)
    }
    
    func subtractTimeUnits(_ timeUnits: Int) {
        self.timeUnits = max(self.timeUnits - timeUnits, 0)
    }

    func getAction(state: Game) -> Action? {
        return nil
    }
    
    // MARK: - Private
    
    private static func addHealthBar(sprite: SKSpriteNode) -> HealthBar {
        let barWidth = sprite.frame.width - 6
        let healthBar = HealthBar(size: CGSize(width: barWidth, height: 6))
        healthBar.position = CGPoint(x: -(barWidth / 2), y: (sprite.frame.height / 2) + 4)
        sprite.addChild(healthBar)
        return healthBar
    }        
}

extension Actor: HitPointsDelegate {
    func hitPointsChanged(current: Int, total: Int) {
        let percentageHealth = CGFloat(current) / CGFloat(total)
        self.healthBar.update(health: percentageHealth)
    }
}
