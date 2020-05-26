//
//  DungeonConfigurationExtensions.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 26/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import DungeonBuilder

/*
{
    "name": "First Encounter",
    "dungeon": {
        "layout": "square",
        "size": "medium",
        "room": {
            "layout": "dense",
            "size": "medium",
            "doors": "basic",
        },
        "corridor": {
            "layout": "straight",
            "removeDeadEnds": "all",
        }
    }
}
*/

extension Configuration {
    convenience init(json: [String : Any]) {
        let name = json["name"] as! String
        print("loading name: \(name)")
        
        let dungeonInfo = json["dungeon"] as! [String: String]
        
        self.init(dungeonSize: .small, dungeonLayout: .square, roomSize: .small, roomLayout: .dense, corridorLayout: .straight, deadEndRemoval: .some, doors: .none)
    }
}
