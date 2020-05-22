//
//  Level.swift
//  Quest iOS
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit
import DungeonBuilder

struct Level: CustomStringConvertible {
    lazy var width: Int32 = { Int32(self.dungeon.width) }()
    lazy var height: Int32 = { Int32(self.dungeon.height) }()
    
    var roomInfo: [UInt: Room] { self.dungeon.roomInfo }

    private let dungeon: Dungeon
    
    init() {
        let dungeonConfiguration = Configuration(
            dungeonSize: DungeonSize.large,
            dungeonLayout: .rectangle,
            roomSize: .medium,
            roomLayout: .dense,
            corridorLayout: .straight,
            deadEndRemoval: .all,
            doors: .basic
        )
            
        let builder = DungeonBuilder(configuration: dungeonConfiguration)
        self.dungeon = builder.build(name: "First Encounter")
    }
    
    func getRoomId(at coord: vector_int2) -> UInt? {
        let node = self.dungeon[Coordinate(Int(coord.x), Int(coord.y))]
                
        if node.contains(.room) {
            return node.roomId
        }
        return nil
    }
            
    subscript(coord: vector_int2) -> Int {
        let node = self.dungeon[Coordinate(Int(coord.x), Int(coord.y))]
                
        if node.contains(.room) || node.contains(.door) || node.contains(.corridor) {
            return 0
        }
        
        return 1
    }
    
    var description: String {
        return self.dungeon.description
    }
}
