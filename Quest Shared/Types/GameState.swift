//
//  GameState.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 26/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import DungeonBuilder
import simd

enum NodeType: Int {
    case open = 0
    case blocked = 1
    case door = 2
}

class GameState: CustomStringConvertible {
    lazy var width: Int32 = { Int32(self.dungeonInternal.width) }()
    lazy var height: Int32 = { Int32(self.dungeonInternal.height) }()

    private let dungeonInternal: Dungeon
    
    // level tiles used for walls, floor, etc...
    private(set) var dungeon: [[NodeType]] = []
    
    var hero: Hero
    
    private var activeActorIndex: Int = 0
    
    private var loot: [Lootable] { self.entities.filter({ $0 is Lootable }) as! [Lootable] }

    var entities: [Entity] = []

    var activeActors: [Actor] = []
    
    var currentActor: Actor { self.activeActors[self.activeActorIndex] }
    
    init(level: Int, hero: Hero, entityFactory: EntityFactory) throws {
        self.hero = hero
        
        let json = try DataLoader.loadLevel(index: level)

        let name = json["name"] as! String
        let configuration = DungeonConfiguration(json: json["dungeon"] as! [String: Any])
        let builder = DungeonBuilder(configuration: configuration)
        self.dungeonInternal = builder.build(name: name)
        print(self.dungeonInternal)
                                
        configure(for: self.dungeonInternal, entityFactory: entityFactory)
    }
    
    private func configure(for dungeon: Dungeon, entityFactory: EntityFactory) {
        var nodes: [[NodeType]] = []
        
        for x in 0 ..< dungeon.width {
            var row: [NodeType] = []
            
            for y in (0 ..< dungeon.height) {
                let node = dungeon[Coordinate(x, y)]
                switch node {
                case _ where node.contains(.door): row.append(.door)
                case _ where node.contains(.corridor) || node.contains(.room): row.append(.open)
                default: row.append(.blocked)
                }
            }
                        
            nodes.append(row)
        }
        
        self.dungeon = nodes
        
        let room = self.dungeonInternal.roomInfo[1]!
        self.hero.coord = vector_int2(Int32(room.coord.y), Int32(room.coord.x))
        
        self.entities.append(self.hero)
        
        addMonsters(entityFactory: entityFactory)
    }
    
    func getLoot(at coord: vector_int2) -> Lootable? {
        return self.loot.filter{ $0.coord == coord }.first
    }
    
    public func nextActor() {
        
    }
            
//        if let roomId = level.getRoomId(at: coord), roomPotionInfo[roomId] == nil, [2, 8, 9].contains(roomId), let room = level.roomInfo[roomId] {
//            let coord = vector_int2(Int32(room.coord.x + room.width - 2), Int32(room.coord.y + room.height - 2))
//            let potion = try! entityFactory.newEntity(type: Potion.self, name: "Health Potion", coord: coord)
//            entities.append(potion)
//            print("potion added to room: \(roomId) @ \(coord.x).\(coord.y)")
//
//            roomPotionInfo[roomId] = coord
//        }
    
    subscript(coord: vector_int2) -> NodeType {
        return self.dungeon[Int(coord.y)][Int(coord.x)]
    }
    
    var description: String {
        var description: String = ""
        
        for y in 0 ..< Int(self.height) {
            for x in 0 ..< Int(self.width) {
                if self.hero.coord == vector_int2(Int32(x), Int32(y)) {
                    description += "H "
                }
                
                let value = self.dungeon[x][y]
                switch value {
                case .open: description += "` "
                case .blocked: description += "  "
                case .door: description += "Π "
                }
            }
            description += "\n"
        }
        
        return description
    }
    
    func remove(entity: Entity) {
        self.entities.removeAll(where: { $0 == entity })
    }
    
    private func addMonsters(entityFactory: EntityFactory) {
        var monsterCount = 0
        for (roomId, room) in self.dungeonInternal.roomInfo {
            // TODO: fix room coord calc in DungeonBuilder, so we don't have to do the following to get good coords ...
            let roomCoord = vector_int2(Int32(room.coord.y + room.height / 2), Int32(room.coord.x + room.width / 2))
            
            var monster: Monster
            
            print("\(roomId): \(room.coord.x).\( room.coord.y) -> \(roomCoord.x).\(roomCoord.y)")
            let v = monsterCount.remainderReportingOverflow(dividingBy: 3).partialValue
            switch v {
            case 0:
                monster = try! entityFactory.newEntity(type: Monster.self, name: "Gnoll", coord: roomCoord)
            case 1:
                monster = try! entityFactory.newEntity(type: Monster.self, name: "Skeleton", coord: roomCoord)
            default:
                monster = try! entityFactory.newEntity(type: Monster.self, name: "Kobold", coord: roomCoord)
            }
            self.entities.append(monster)
            
            monsterCount += 1
        }
    }
}
