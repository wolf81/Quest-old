//
//  Dungeon.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 18/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

public class Dungeon {
    private let dungeon: DungeonInternal
    
    public var width: Int { self.dungeon.width }
    public var height: Int { self.dungeon.height }
        
    internal init(dungeon: DungeonInternal) {
        self.dungeon = dungeon
    }
    
    /// Retrieve a node from the dungeon.
    public subscript(coord: Coordinate) -> Node {
        return self.dungeon.nodes[coord.y][coord.x]
    }
    
    /// Returns a dictionary of room ids and room data
    public lazy var roomInfo: [UInt: Room] = {
        var roomInfo: [UInt: Room] = [:]
                
        for (roomId, room) in self.dungeon.rooms {
            let x = Int(room.coord.y * 2 + 1)
            let y = Int(room.coord.x * 2 + 1)
            roomInfo[roomId] = Room(i: x, j: y, width: room.width * 2 + 1, height: room.height * 2 + 1)
        }
        
        return roomInfo
    }()
}

// MARK: - CustomStringConvertible

extension Dungeon: CustomStringConvertible {
    public var description: String {
        var output = "\n"
        
        for y in 0 ..< self.height {
            for x in 0 ..< self.width {
                let node = self[Coordinate(x, y)]

                switch node {
                case let node where node.label != nil: output += " \(node.label!)"
                case _ where node.intersection(.doorspace) != .nothing:
                    switch node {
                    case _ where node.contains(.arch): output += " ∩"
                    case _ where node.contains(.locked): output += " Φ"
                    case _ where node.contains(.trapped): output += " ‼"
                    case _ where node.contains(.secret): output += " ⁑"
                    case _ where node.contains(.portcullis): output += " ‡"
                    case _ where node.contains(.door): fallthrough
                    default: output += " Π"
                    }
                case _ where node.contains(.room): output += " `"
                case _ where node.contains(.corridor): output += " •"
                default: output += "  "
                }
            }
            output += "\n"
        }
        
        output += """
        ┌─── LEGEND ──────────────────────────────┐
        │ 1+ room nr.   ∩  arch     ⁑  secret     │
        │ `  room       Π  door     ‼  trapped    │
        │ •  corridor   Φ  locked   ‡  portcullis │
        └─────────────────────────────────────────┘
        
        """
        
        for (roomId, room) in roomInfo.sorted(by: { (kv1, kv2) -> Bool in
            kv1.key < kv2.key
        }) {
            output += "\(roomId) @ \(room.coord.x).\(room.coord.y) (\(room.width) x \(room.height)) \n"
        }
        
        return output
    }
}
