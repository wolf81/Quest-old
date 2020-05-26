//
//  GameState.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 26/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import DungeonBuilder

class GameState {
    let dungeon: Dungeon
    
    init(level: Int) throws {
        self.dungeon = try DataLoader.loadLevel(index: level)
        
//        let dungeonConfiguration = DungeonConfiguration(
//            dungeonSize: .large,
//            dungeonLayout: .rectangle,
//            roomSize: .medium,
//            roomLayout: .dense,
//            corridorLayout: .straight,
//            deadEndRemoval: .all,
//            doors: .basic
//        )
//            
//        let builder = DungeonBuilder(configuration: dungeonConfiguration)
//        let dungeon = builder.build(name: "First Encounter")
                        
    }
}
