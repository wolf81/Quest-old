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
    
//    fileprivate let tiles: [Int]
    
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
        print(dungeon)

        self.width = Int32(dungeon.width)
        self.height = Int32(dungeon.height)

//        var tiles = Array(repeatElement(0, count: Int(dungeon.width) * Int(dungeon.height)))
        
        for x in (0 ..< dungeon.width) {
            for y in (0 ..< dungeon.height) {
                let idx = y * dungeon.width + x
                let node = dungeon[x, y]
//                if node.contains(.openspace) {
//                    tiles[idx] = 0
//                } else {
//                    tiles[idx] = 1
//                }
//                let idx = Int(y * width + x)
//
//                if x == 2 && y == 2 {
//                    tiles[idx] = 3
//                    continue
//                 }
//
//                if y == 0 {
//                    tiles[idx] = 1
//                }
//
//                if x == 0 {
//                    tiles[idx] = 1
//                }
//
//                if y == (height - 1) {
//                    tiles[idx] = 1
//                }
//
//                if x == (width - 1) {
//                    tiles[idx] = 1
//                }
//
//                if x == 7 && y < 7 {
//                    tiles[idx] = 1
//                }
//
//                if x == 12 && y > 3 {
//                    tiles[idx] = 1
//                }
            }
        }
            
//        self.tiles = tiles
    }
    
    func getRoomId(coord: vector_int2) -> Int? {
        let node = self.dungeon[Int(coord.x), Int(coord.y)]
        if node.contains(.room) {
            return Int(node.roomId)
        }
        return nil
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

