//
//  GameState.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 26/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import DungeonBuilder
import GameplayKit
import simd

enum NodeType: Int {
    case open = 0
    case blocked = 1
    case door = 2
}

class GameState {
    private var map: [[NodeType]] = []

    lazy var mapSize: CGSize = { CGSize(width: Int(self.mapWidth), height: Int(self.mapHeight)) }()
    lazy var mapWidth: Int32 = { Int32(self.map[0].count) }()
    lazy var mapHeight: Int32 = { Int32(self.map.count) }()

//    private let dungeonInternal: Dungeon
        
    var hero: Hero
    
    private var activeActorIndex: Int = 0
    
    private var loot: [Lootable] { self.entities.filter({ $0 is Lootable }) as! [Lootable] }

    var entities: [Entity] = []

    private var actors: [Actor] { self.entities.filter({ $0 is Actor }) as! [Actor] }
        
    private(set) var tiles: [[TileProtocol]] = []
        
    var actorVisibleCoords = Set<vector_int2>()

    var activeActors: [Actor] = []
    
    var currentActor: Actor { self.activeActors[self.activeActorIndex] }
    
    init(level: Int, hero: Hero, entityFactory: EntityFactory) throws {
        self.hero = hero
        
        let json = try DataLoader.loadLevel(index: level)

        let name = json["name"] as! String
        let configuration = DungeonConfiguration(json: json["dungeon"] as! [String: Any])
        let builder = DungeonBuilder(configuration: configuration)
        let dungeon = builder.build(name: name)
        print(dungeon)
                                
        configure(for: dungeon, entityFactory: entityFactory)
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
        
        self.map = nodes
        
        addTiles(to: dungeon, entityFactory: entityFactory)
        addMonsters(to: dungeon, entityFactory: entityFactory)
        addLoot(to: dungeon, entityFactory: entityFactory)
        addHero(to: dungeon, roomId: 1)
    }
    
    func getLoot(at coord: vector_int2) -> Lootable? {
        return self.loot.filter{ $0.coord == coord }.first
    }
    
    func nextActor() {
        self.activeActorIndex = (self.activeActorIndex + 1) % self.activeActors.count
    }
    
    func updateActiveActors() {
        self.activeActors.removeAll()
        
        let xRange = max(self.hero.coord.x - 10, 0) ... min(self.hero.coord.x + 10, self.mapWidth)
        let yRange = max(self.hero.coord.y - 10, 0) ... min(self.hero.coord.y + 10, self.mapHeight)
        
        for actor in self.actors {
            if xRange.contains(actor.coord.x) && yRange.contains(actor.coord.y) {
                self.activeActors.append(actor)
            }
        }
        
        self.activeActorIndex = 0
    }
    
    func getDoor(at coord: vector_int2) -> Door? {
        let tile = self.tiles[Int(coord.y)][Int(coord.x)]
        return tile as? Door
    }
    
    func getActor(at coord: vector_int2) -> Actor? {
        self.actors.filter({ $0.coord == coord }).first
    }

    func getMovementGraph(for actor: Actor, range: Int32, excludedCoords: [vector_int2]) -> GKGridGraph<GKGridGraphNode> {
        let xRange = getRange(position: actor.coord.x, radius: range, constrainedTo: 0 ..< self.mapWidth)
        let width = xRange.upperBound - xRange.lowerBound
        let yRange = getRange(position: actor.coord.y, radius: range, constrainedTo: 0 ..< self.mapHeight)
        let height = yRange.upperBound - yRange.lowerBound
        
        // Create a graph for the visible area
        let movementGraph = GKGridGraph(fromGridStartingAt: vector_int2(xRange.lowerBound, yRange.lowerBound), width: width, height: height, diagonalsAllowed: false)
        for x in movementGraph.gridOrigin.x ..< (movementGraph.gridOrigin.x + Int32(movementGraph.gridWidth)) {
            for y in movementGraph.gridOrigin.y ..< (movementGraph.gridOrigin.y + Int32(movementGraph.gridHeight)) {
                let coord = vector_int2(x, y)
                                
                if self.actorVisibleCoords.contains(coord) == false || self[coord] == .blocked {
                    if let node = movementGraph.node(atGridPosition: coord) {
                        movementGraph.remove([node])
                    }
                }
                
                if excludedCoords.contains(coord) {
                    if let movementGraphNode = movementGraph.node(atGridPosition: coord) {
                        movementGraph.remove([movementGraphNode])
                    }
                }
            }
        }
        
        if let actorNode = movementGraph.node(atGridPosition: actor.coord) {
            for node in movementGraph.nodes ?? [] {
                let pathNodes = actorNode.findPath(to: node)
                if pathNodes.count == 0 {
                    movementGraph.remove([node])
                }
            }
        }

        return movementGraph
    }
    
    func getRange(position: Int32, radius: Int32, constrainedTo range: Range<Int32>) -> Range<Int32> {
        let minValue = max(position - radius, range.lowerBound)
        let maxValue = min(position + radius + 1, range.upperBound)
        return Int32(minValue) ..< Int32(maxValue)
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
        return self.map[Int(coord.y)][Int(coord.x)]
    }
        
    func remove(entity: Entity) {
        self.entities.removeAll(where: { $0 == entity })
    }
    
    func canMove(entity: Entity, to coord: vector_int2) -> Bool {
        guard self.getActor(at: coord) == nil else {
            return false
        }

        let node = self[coord]
        
        if node == .door {
            let door = self.tiles[Int(coord.y)][Int(coord.x)] as! Door
            return door.isOpen
        }
        
        return node == .open
    }
    
    // MARK: - Private
    
    private func addTiles(to dungeon: Dungeon, entityFactory: EntityFactory) {
        var tiles: [[TileProtocol]] = []
                       
        let tileset = try! DataLoader.load(type: Tileset.self, fromFileNamed: "catacombs", inDirectory: "Data/Tileset")

        for y in (0 ..< Int32(self.mapHeight)) {
           var tileRow: [TileProtocol] = []
           
           for x in (0 ..< Int32(self.mapWidth)) {
               let coord = vector_int2(x, y)
               let tile = self[coord]
               var entity: TileProtocol

               switch tile {
               case .open: entity = Tile(sprite: tileset.getFloorTile(), coord: coord)
               case .blocked: entity = Tile(sprite: tileset.getWallTile(), coord: coord)
               case .door: entity = try! entityFactory.newEntity(type: Door.self, name: "Door", coord: coord)
               }

               tileRow.append(entity)
           }
           tiles.append(tileRow)
        }
        
        self.tiles = tiles
    }
    
    private func addLoot(to dungeon: Dungeon, entityFactory: EntityFactory) {
        let roomCount = dungeon.roomInfo.count
        
        var lootRoomIds: [UInt] = []
        
        let lootCount = max(roomCount / 1, 1)
        while lootRoomIds.count < lootCount {
            let roomId = UInt(arc4random_uniform(UInt32(roomCount))) + 1
            
            if lootRoomIds.contains(roomId) { continue }
            
            let room = dungeon.roomInfo[roomId]!
            let coord = vector_int2(Int32(room.coord.y + room.height - 1), Int32(room.coord.x + room.width - 1))
            let potion = try! entityFactory.newEntity(type: Potion.self, name: "Health Potion", coord: coord)
            self.entities.append(potion)
            
            lootRoomIds.append(roomId)
        }
    }
    
    private func addMonsters(to dungeon: Dungeon, entityFactory: EntityFactory) {
        var monsterCount = 0
        for (_, room) in dungeon.roomInfo {
            // TODO: fix room coord calc in DungeonBuilder, so we don't have to do the following to get good coords ...
            let roomCoord = vector_int2(Int32(room.coord.y + room.height / 2), Int32(room.coord.x + room.width / 2))
            
            var monster: Monster
            
            let remainder = monsterCount.remainderReportingOverflow(dividingBy: 3).partialValue
            switch remainder {
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
    
    private func addHero(to dungeon: Dungeon, roomId: UInt) {
        let room = dungeon.roomInfo[roomId]!
        self.hero.coord = vector_int2(Int32(room.coord.y), Int32(room.coord.x))
        self.entities.append(self.hero)
    }
}

extension GameState: CustomStringConvertible {
    var description: String {
        var description: String = ""
        
        for x in (0 ..< Int(self.mapWidth)).reversed() {
            for y in 0 ..< Int(self.mapHeight) {
                let coord = vector_int2(Int32(y), Int32(x))
                if let actor = getActor(at: coord) {
                    description += actor is Hero ? "H " : "M "
                    continue
                }
                
                if let loot = getLoot(at: coord) {
                    description += "L "
                    continue
                }

                let value = self.map[x][y]
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
}
