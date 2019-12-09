//
//  Skill.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

typealias Skill = Int

struct Skills: CustomStringConvertible {
    let physical: Skill
    let subterfuge: Skill
    let knowledge: Skill
    let communication: Skill
    
    public init() {
        self.physical = 0
        self.subterfuge = 0
        self.knowledge = 0
        self.communication = 0
    }
    
    public init(physical: Skill, subterfuge: Skill, knowledge: Skill, communication: Skill) {
        self.physical = physical
        self.subterfuge = subterfuge
        self.knowledge = knowledge
        self.communication = communication
    }
    
    public init(json: [String: Int], defaultValue: Int) {
        // TODO: consider instead of default value, add base value in constructor and use the other
        // values as modifiers on the base value ... perhaps JSON should also reflect this (e.g.
        // +3 instead of 3 for a skill)
        self.knowledge = json["knowledge"] ?? defaultValue
        self.physical = json["physical"] ?? defaultValue
        self.subterfuge = json["subterfuge"] ?? defaultValue
        self.communication = json["communication"] ?? defaultValue
    }
    
    var description: String {
        return "PHY: \(self.physical), SUB: \(self.subterfuge), KNO: \(self.knowledge), COM: \(self.communication)"
    }
}
