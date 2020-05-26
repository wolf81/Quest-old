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

extension DungeonConfiguration {
    convenience init(json: [String : Any]) {
        let dungeonSize = DungeonSize(rawValue: json["size"] as! String)!
        let dungeonLayout = DungeonLayout(rawValue: json["layout"] as! String)!

        let corridorInfo = json["corridor"] as! [String: String]
        let corridorLayout = CorridorLayout(rawValue: corridorInfo["layout"]!)!
        let corridorDeadEndRemoval = DeadEndRemoval(rawValue: corridorInfo["deadEndRemoval"]!)!
        
        let roomInfo = json["room"] as! [String: String]
        let roomDoors = Doors(rawValue: roomInfo["doors"]!)!
        let roomLayout = RoomLayout(rawValue: roomInfo["layout"]!)!
        let roomSize = RoomSize(rawValue: roomInfo["size"]!)!
        
        self.init(
            dungeonSize: dungeonSize,
            dungeonLayout: dungeonLayout,
            roomSize: roomSize,
            roomLayout: roomLayout,
            corridorLayout: corridorLayout,
            deadEndRemoval: corridorDeadEndRemoval,
            doors: roomDoors)
    }
}
