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
    private var name: String!
    private var gender: Gender!
    private var race: Race!
    private var role: Role!
    private var attributes: Attributes!
    private var equipment: Equipment!
    
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
    
    func with(equipment: Equipment) -> Self {
        self.equipment = equipment
        return self
    }
    
    func build() throws -> Hero {
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
            equipment: self.equipment
        )
    }
}
