//
//  Configuration.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

open class Configuration {
    let dungeonLayout: DungeonLayout
    let dungeonSize: DungeonSize
    let roomLayout: RoomLayout
    let roomSize: RoomSize
    let corridorLayout: CorridorLayout
    let deadEndRemoval: DeadEndRemoval
    let doors: Doors
    
    var closeArcs: Bool {
        let closeArcCorridors: [CorridorLayout] = [.straight, .errant]
        return closeArcCorridors.contains(self.corridorLayout)
    }
    
    public init(dungeonSize: DungeonSize,
         dungeonLayout: DungeonLayout,
         roomSize: RoomSize,
         roomLayout: RoomLayout,
         corridorLayout: CorridorLayout,
         deadEndRemoval: DeadEndRemoval,
         doors: Doors) {
        self.dungeonSize = dungeonSize
        self.dungeonLayout = dungeonLayout
        self.roomSize = roomSize
        self.roomLayout = roomLayout
        self.corridorLayout = corridorLayout
        self.deadEndRemoval = deadEndRemoval
        self.doors = doors
    }
    
    public static var Default: Configuration {
        return Configuration(
            dungeonSize: .medium,
            dungeonLayout: .rectangle,
            roomSize: .medium,
            roomLayout: .scattered,
            corridorLayout: .errant,
            deadEndRemoval: .all,
            doors: .standard
        )
    }
}
