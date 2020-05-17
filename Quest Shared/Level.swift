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

struct Level {
    let width: Int32
    let height: Int32
    
    private let dungeon: Dungeon
    
    init() {
        let dungeonConfiguration = Configuration(
            dungeonSize: DungeonSize.tiny,
            dungeonLayout: .rectangle,
            roomSize: .medium,
            roomLayout: .dense,
            corridorLayout: .straight,
            deadEndRemoval: .all,
            doors: .basic
        )
            
        let builder = DungeonBuilder(configuration: dungeonConfiguration)
        self.dungeon = builder.build(name: "First Encounter")
        print(dungeon)
        
        self.width = Int32(dungeon.width)
        self.height = Int32(dungeon.height)
        
        for room in self.dungeon.rooms.sorted(by: { (kv1, kv2) -> Bool in
            kv1.key < kv2.key
        }) {
            print("[\(room.key)]: \(room.value.coord.y * 2 + 1).\(self.height - 1 - (room.value.coord.x * 2 + 1)) - \(room.value.width * 2 + 1) x \(room.value.height * 2 + 1)")
        }
    }
    
    func getRoomId(coord: vector_int2) -> Int? {
        let node = self.dungeon[Int(coord.x), Int(coord.y)]
        if node.contains(.room) {
            return Int(node.roomId)
        }
        return nil
    }
    
    func getRoomInfo() -> [UInt: Room] {
        return self.dungeon.rooms
    }
    
    func getTileAt(coord: vector_int2) -> Int {
        let node = self.dungeon[Int(coord.x), Int(coord.y)]
        if node.contains(.room) || node.contains(.door) || node.contains(.corridor) {
            return 0
        }
        
        return 1
    }
}

extension Level : CustomStringConvertible {
    var description: String {
        var output = ""
        
        for y in (0 ..< height) {
            for x in (0 ..< width) {
                let idx = Int(y * width + x)
                
//                output += "\(tiles[idx]) "
            }
            output += "\n"
        }
        
        return output
    }
}

