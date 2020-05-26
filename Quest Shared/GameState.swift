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

class GameState {
    private var map: Map = Map()

    lazy var mapSize: CGSize = { CGSize(width: Int(self.mapWidth), height: Int(self.mapHeight)) }()
    lazy var mapWidth: Int32 = { Int32(self.map[0].count) }()
    lazy var mapHeight: Int32 = { Int32(self.map.count) }()

    var hero: Hero
    
    var actorVisibleCoords = Set<vector_int2>()

    var entities: [Entity] = []

    var activeActors: [Actor] = []

    var currentActor: Actor { self.activeActors[self.activeActorIndex] }

    var loot: [Lootable] { self.entities.filter({ $0 is Lootable }) as! [Lootable] }

    var monsters: [Monster] { self.entities.filter({ $0 is Monster }) as! [Monster] }

    let mainTilesetName: String
    
    let altTilesetNames: [String]
    
    private var actors: [Actor] { self.entities.filter({ $0 is Actor }) as! [Actor] }
        
    private var activeActorIndex: Int = 0

    private(set) var tiles: [[TileProtocol]] = []
                    
    init(level: Int, hero: Hero, entityFactory: EntityFactory) throws {
        self.hero = hero
        
        let json = try DataLoader.loadLevel(index: level)

        let name = json["name"] as! String
        let configuration = DungeonConfiguration(json: json["dungeon"] as! [String: Any])
        let builder = DungeonBuilder(configuration: configuration)
        let dungeon = builder.build(name: name)
        print(dungeon)
        
        let tilesetInfo = json["tilesets"] as! [String: Any]
        self.mainTilesetName = tilesetInfo["main"] as! String
        self.altTilesetNames = tilesetInfo["alt"] as! [String]
                                
        configure(for: dungeon, entityFactory: entityFactory)
    }
    
    private func configure(for dungeon: Dungeon, entityFactory: EntityFactory) {
        var map = Map()
        
        for x in 0 ..< dungeon.width {
            var mapRow: [NodeType] = []
            
            for y in (0 ..< dungeon.height) {
                let node = dungeon[Coordinate(x, y)]
                switch node {
                case _ where node.contains(.door): mapRow.append(.door)
                case _ where node.contains(.corridor) || node.contains(.room): mapRow.append(.open)
                default: mapRow.append(.blocked)
                }
            }
                        
            map.append(mapRow)
        }
        
        self.map = map
        
        addTiles(to: dungeon, entityFactory: entityFactory)
        addTilesets(to: dungeon)
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
        let xRange = Functions.getRange(origin: actor.coord.x, radius: range, constrainedTo: 0 ..< self.mapWidth)
        let width = xRange.upperBound - xRange.lowerBound
        let yRange = Functions.getRange(origin: actor.coord.y, radius: range, constrainedTo: 0 ..< self.mapHeight)
        let height = yRange.upperBound - yRange.lowerBound
        
        // Create a graph for the visible area
        let movementGraph = GKGridGraph(fromGridStartingAt: vector_int2(xRange.lowerBound, yRange.lowerBound), width: width, height: height, diagonalsAllowed: false)
        for x in movementGraph.gridOrigin.x ..< (movementGraph.gridOrigin.x + Int32(movementGraph.gridWidth)) {
            for y in movementGraph.gridOrigin.y ..< (movementGraph.gridOrigin.y + Int32(movementGraph.gridHeight)) {
                let coord = vector_int2(x, y)
                                                
                if self.actorVisibleCoords.contains(coord) == false || self.getMapNode(at: coord) == .blocked {
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
    
    func getMapNode(at coord: vector_int2) -> NodeType {
        return self.map[coord]
    }
        
    func remove(entity: Entity) {
        self.entities.removeAll(where: { $0 == entity })
    }
    
    func canMove(entity: Entity, to coord: vector_int2) -> Bool {
        guard self.getActor(at: coord) == nil else {
            return false
        }

        let node = self.map[coord]
        
        switch node {
        case .door: return (self.tiles[Int(coord.y)][Int(coord.x)] as! Door).isOpen
        default: return node == .open
        }
    }
    
    // MARK: - Private
    
    private func addTiles(to dungeon: Dungeon, entityFactory: EntityFactory) {
        var tiles: [[TileProtocol]] = []
                       
        let tileset = try! DataLoader.load(type: Tileset.self, fromFileNamed: self.mainTilesetName, inDirectory: "Data/Tileset")

        for y in (0 ..< Int32(self.mapHeight)) {
           var tileRow: [TileProtocol] = []
           
           for x in (0 ..< Int32(self.mapWidth)) {
               let coord = vector_int2(x, y)
               let node = self.map[coord]
               var entity: TileProtocol

               switch node {
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
        
        let lootCount = max(roomCount / 6, 1)
        while lootRoomIds.count < lootCount {
            let roomId = UInt(arc4random_uniform(UInt32(roomCount))) + 1
            
            if lootRoomIds.contains(roomId) { continue }
            
            let room = dungeon.roomInfo[roomId]!
            let coord = vector_int2(Int32(room.coord.y + room.height - 2), Int32(room.coord.x + room.width - 2))
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
    
    private func addTilesets(to dungeon: Dungeon) {
        var tilesets: [Tileset] = []
        for tilesetFile in self.altTilesetNames {
            let tileset = try! DataLoader.load(type: Tileset.self, fromFileNamed: tilesetFile, inDirectory: "Data/Tileset")
            tilesets.append(tileset)
        }
                        
        var roomTilesetInfo: [UInt: Bool] = [:]
                
        for (roomId, room) in dungeon.roomInfo {
            if arc4random_uniform(6) != 0 || roomTilesetInfo.index(forKey: roomId) != nil { continue }
                        
            let midX: Int32 = Int32(room.coord.x + room.width / 2)
            let midY: Int32 = Int32(room.coord.y + room.height / 2)

            let minY = Int32(max(room.coord.x - 2, 0))
            let maxY = Int32(min(room.coord.x + room.width + 2, Int(self.mapWidth - 1)))
            let minX = Int32(max(room.coord.y - 2, 0))
            let maxX = Int32(min(room.coord.y + room.height + 2, Int(self.mapHeight - 1)))
            let p1 = vector_int2(minX, midY)
            let p2 = vector_int2(maxX, midY)
            let p3 = vector_int2(midX, minY)
            let p4 = vector_int2(midX, maxY)
            let p5 = vector_int2(minX, minY)
            let p6 = vector_int2(maxX, minY)
            let p7 = vector_int2(minX, maxY)
            let p8 = vector_int2(maxX, maxY)

            for point in [p1, p2, p3, p4, p5, p6, p7, p8] {
                let coord = Coordinate(Int(point.y), Int(point.x))
                let node = dungeon[coord]
                if node.contains(.room) {
                    roomTilesetInfo[node.roomId] = false
                }
            }
                        
            roomTilesetInfo[roomId] = true
            
            let tilesetIdx = arc4random_uniform(UInt32(tilesets.count))
            let tileset = tilesets[Int(tilesetIdx)]
            
            for x in (room.coord.x - 1) ... (room.coord.x + room.width) {
                for y in (room.coord.y - 1) ... (room.coord.y + room.height) {
                    let tile = self.tiles[x][y]

                    let coord = vector_int2(Int32(y), Int32(x))
                    let node = self.getMapNode(at: coord)

                    var sprite: SKSpriteNode
                    
                    switch node {
                    case .open: sprite = tileset.getFloorTile()
                    case .blocked: sprite = tileset.getWallTile()
                    default: continue // ignore doors for now?
                    }
                    
                    let newTile = Tile(sprite: sprite, coord: tile.coord)
                    self.tiles[x][y] = newTile
                }
            }
        }
    }
}

// MARK: - CustomStringConvertible

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
                
                if let _ = getLoot(at: coord) {
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
