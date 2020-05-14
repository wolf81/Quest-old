//
//  HeroBuilder.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

enum HeroBuilderError: LocalizedError {
    case missingValue(String)
}

class HeroBuilder {
    private(set) var name: String!
    private(set) var gender: Gender!
    private(set) var race: Race!
    private(set) var role: Role!
    private(set) var attributes: Attributes!
    private(set) var equipment: [Equippable]!
    private(set) var backpack: [Lootable]!
        
    func with(gender: Gender) -> Self {
        self.gender = gender
        return self
    }
    
    func with(race: Race) -> Self {
        self.race = race
        return self
    }
    
    func with(role: Role) -> Self {
        self.role = role
        return self
    }
        
    func with(attributes: Attributes) -> Self {
        self.attributes = attributes
        return self
    }
    
    func with(name: String) -> Self {
        self.name = name
        return self
    }
    
    func with(equipment: [Equippable]) -> Self {
        self.equipment = equipment
        return self
    }
    
    func with(backpack: [Lootable]) -> Self {
        self.backpack = backpack
        return self
    }
    
    func build(entityFactory: EntityFactory) throws -> Hero {
        // Parse all properties, raise an error if a property was not set
        for child in Mirror(reflecting: self).children {
            if case Optional<Any>.none = child.value {
                throw HeroBuilderError.missingValue(child.label!)
            }
        }
        
        var physical: Skill = self.role == .fighter ? 3 : 0
        var subterfuge: Skill = self.role == .rogue ? 3 : 0
        var knowledge: Skill = self.role == .mage ? 3 : 0
        var communication: Skill = self.role == .cleric ? 3 : 0
        
        if self.race == .human {
            physical += 1
            subterfuge += 1
            knowledge += 1
            communication += 1
        }

        return Hero(
            name: self.name,
            race: self.race,
            gender: self.gender,
            role: self.role,
            attributes: self.attributes,
            skills: Skills(physical: physical, subterfuge: subterfuge, knowledge: knowledge, communication: communication),
            equipment: self.equipment,
            backpack: self.backpack,
            entityFactory: entityFactory
        )
    }
}
