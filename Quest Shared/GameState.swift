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
import Fenris
import Harptos

class GameState {
    private var map: Map = Map()

    lazy var mapSize: CGSize = { CGSize(width: Int(self.mapWidth), height: Int(self.mapHeight)) }()
    lazy var mapWidth: Int32 = { Int32(self.map[0].count) }()
    lazy var mapHeight: Int32 = { Int32(self.map.count) }()

    var hero: Hero

    let entityFactory: EntityFactory
    
    var round: Int = 1
    
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
    
    private var movementGraph: GKGridGraph<GKGridGraphNode>!
                        
    init(level: Int, hero: Hero, entityFactory: EntityFactory) throws {
        self.entityFactory = entityFactory
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
                                
        configure(for: dungeon)
    }
    
    private func configure(for dungeon: Dungeon) {
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
        
        addTiles(to: dungeon)
        addTilesets(to: dungeon)
        addMonsters(to: dungeon)
        addLoot(to: dungeon)
        addHero(to: dungeon, roomId: 1)
        addTraps(to: dungeon)
        
        generateMovementGraph()
        
        for actor in self.actors {
            setRaycastVisibility(for: actor)
            actor.updateVisibility()
        }
    }
    
    func getTrap(at coord: vector_int2) -> Trap? {
        guard let trap = self.tiles[Int(coord.y)][Int(coord.x)] as? Trap, trap.isActive else {
            return nil
        }
        return trap
    }
    
    func getLoot(at coord: vector_int2) -> Lootable? {
        return self.loot.filter{ $0.coord == coord }.first
    }
    
    func nextActor() {
        self.activeActorIndex = (self.activeActorIndex + 1) % self.activeActors.count
    }
    
    func updateActiveActors(for coords: Set<vector_int2>) {        
        self.activeActors.removeAll()
                
        for actor in self.actors {
            if Functions.distanceBetween(actor.coord, self.hero.coord) <= actor.sight {
                self.activeActors.append(actor)
            }
                // TODO: filter on sight range of actor ... calc distance between coords + 1
        }
        
        if self.activeActors.isEmpty {
            self.activeActors.append(self.hero)
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
        
    func getMapNodeType(at coord: vector_int2) -> NodeType {
        return self.map[coord]
    }
        
    func remove(entity: Entity) {
        self.entities.removeAll(where: { $0 == entity })
    }
    
    func spawnMonster(at coord: vector_int2) -> Monster {
        let monsters = self.entityFactory.entityNames(of: Monster.self)
        let monsterName = monsters.randomElement()!
        let monster = try! self.entityFactory.newEntity(type: Monster.self, name: monsterName, coord: coord)
        setRaycastVisibility(for: monster)
        self.entities.append(monster)
        
        if self.hero.visibleCoords.contains(monster.coord) {
            self.activeActors.append(monster)
            let actorIdx = self.activeActors.firstIndex(of: monster)!
            self.activeActorIndex = actorIdx
        }
        
        return monster
    }
    
    func findPath(from coord: vector_int2, to toCoord: vector_int2) -> [vector_int2] {
        guard
            let startNode = self.movementGraph.node(atGridPosition: coord),
            let endNode = self.movementGraph.node(atGridPosition: toCoord) else { return [] }
        
        let path = self.movementGraph.findPath(from: startNode, to: endNode) as! [GKGridGraphNode]
        
        return path.compactMap({ $0.gridPosition })
    }
    
    func canMove(entity: Entity, to coord: vector_int2) -> Bool {
        guard self.getActor(at: coord) == nil else {
            return false
        }

        let nodeType = self.map[coord]
        
        switch nodeType {
        case .door: return getDoor(at: coord)!.isOpen
        default: return nodeType == .open
        }
    }
    
    func isEnemyNearHero() -> Bool {
        let maxRange: Int32 = 7
        let xRange = max((self.hero.coord.x - maxRange), 0) ... min((self.hero.coord.x + maxRange), self.mapWidth)
        let yRange = max((self.hero.coord.y - maxRange), 0) ... min((self.hero.coord.y + maxRange), self.mapHeight)
        
        for x in xRange {
            for y in yRange {
                let coord = vector_int2(x, y)
                
                let distance = Functions.distanceBetween(self.hero.coord, coord)
                guard distance <= maxRange else { continue }
                
                if let _ = getActor(at: coord) as? Monster {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - Private
    
    private func setRaycastVisibility(for actor: Actor) {
        actor.visibility = RaycastVisibility(mapSize: self.mapSize, blocksLight: {
            if let door = self.getDoor(at: $0) {
                return door.isOpen == false
            }
                            
            return self.getMapNodeType(at: $0) == .blocked
        }, setVisible: {
            actor.visibleCoords.insert($0)
        }, getDistance: {
            return Functions.distanceBetween($0, $1)
        })
    }
    
    private func addTiles(to dungeon: Dungeon) {
        var tiles: [[TileProtocol]] = []
                       
        let tileset = try! DataLoader.load(type: Tileset.self, fromFileNamed: self.mainTilesetName, inDirectory: "Data/Tileset")

        for y in (0 ..< self.mapHeight) {
           var tileRow: [TileProtocol] = []
           
           for x in (0 ..< self.mapWidth) {
               let coord = vector_int2(x, y)
               let nodeType = self.map[coord]
               var entity: TileProtocol

               switch nodeType {
               case .open: entity = Tile(sprite: tileset.getFloorTile(), coord: coord)
               case .blocked: entity = Tile(sprite: tileset.getWallTile(), coord: coord)
               case .door: entity = try! self.entityFactory.newEntity(type: Door.self, name: "Door", coord: coord)
               }

               tileRow.append(entity)
           }
           tiles.append(tileRow)
        }
        
        self.tiles = tiles
    }
    
    private func addLoot(to dungeon: Dungeon) {
        let roomCount = dungeon.roomInfo.count
        
        var lootRoomIds: [UInt] = []
        
        let lootCount = max(roomCount / 6, 1)
        while lootRoomIds.count < lootCount {
            let roomId = UInt(arc4random_uniform(UInt32(roomCount))) + 1
            
            if lootRoomIds.contains(roomId) { continue }
            
            let room = dungeon.roomInfo[roomId]!
            let coord = getRandomCoord(in: room)
            let potion = try! self.entityFactory.newEntity(type: Potion.self, name: "Health Potion", coord: coord)
            self.entities.append(potion)
            
            lootRoomIds.append(roomId)
        }
    }
    
    private func addTraps(to dungeon: Dungeon) {
        for (_, room) in dungeon.roomInfo {
            let maxTrapCount = UInt32(floor(cbrt(Float(room.area))))
            var trapCount = arc4random_uniform(maxTrapCount)
            
            while trapCount > 0 {
                let coord = getRandomCoord(in: room)
                guard getTrap(at: coord) == nil else { continue }
                guard getActor(at: coord) != self.hero else { continue }
                
                let tile = self.tiles[Int(coord.y)][Int(coord.x)]
                let trap = try! self.entityFactory.newEntity(type: Trap.self, name: "Arrow Trap", coord: tile.coord)
                trap.configure(withTile: tile)
                self.tiles[Int(coord.y)][Int(coord.x)] = trap
                
                trapCount -= 1
            }
        }
    }
    
    private func addMonsters(to dungeon: Dungeon) {
        var monsterCount = 0
        for (_, room) in dungeon.roomInfo {
            let roomCoord = getRandomCoord(in: room)
            
            // TODO: make sure to not place monsters on top of other entities including the player
            
            // TODO: fix room coord calc in DungeonBuilder, so we don't have to do the following to get good coords ...
//            let roomCoord = vector_int2(Int32(room.coord.y + room.height / 2), Int32(room.coord.x + room.width / 2))
            
            let monsterNames = self.entityFactory.entityNames(of: Monster.self)
            let remainder = monsterCount.remainderReportingOverflow(dividingBy: monsterNames.count).partialValue
            let monster = try! self.entityFactory.newEntity(type: Monster.self, name: monsterNames[remainder], coord: roomCoord)
            self.entities.append(monster)
            
            monsterCount += 1
        }
    }
    
    private func getRandomCoord(in room: Room, insetBy inset: Int = 0) -> vector_int2 {
         let roomCoords = getCoords(in: room, insetBy: inset)
        
//         for y in Int32(room.coord.y + inset) ..< Int32(room.coord.y + room.height - inset) {
//             for x in Int32(room.coord.x + inset) ..< Int32(room.coord.x + room.width - inset) {
//                 let coord = vector_int2(y, x)
//
//                 if self.getMapNodeType(at: coord) == .open {
//                     roomCoords.append(coord)
//                 }
//             }
//         }

        let randomIdx = arc4random_uniform(UInt32(roomCoords.count))
        return roomCoords[Int(randomIdx)]
    }
    
    private func getCoords(in room: Room, insetBy inset: Int) -> [vector_int2] {
        var roomCoords: [vector_int2] = []
        
        for y in Int32(room.coord.y + inset) ..< Int32(room.coord.y + room.height - inset) {
            for x in Int32(room.coord.x + inset) ..< Int32(room.coord.x + room.width - inset) {
                let coord = vector_int2(y, x)
                
                if self.getMapNodeType(at: coord) == .open {
                    roomCoords.append(coord)
                }
            }
        }

        return roomCoords
    }
        
    private func generateMovementGraph() {
        self.movementGraph = GKGridGraph(fromGridStartingAt: vector2(0, 0), width: self.mapWidth, height: self.mapHeight, diagonalsAllowed: false)
        for x in (0 ..< self.mapWidth) {
            for y in (0 ..< self.mapHeight) {
                let coord = vector_int2(x, y)
                if map[coord] == .blocked {
                    if let node = self.movementGraph.node(atGridPosition: coord) {
                        self.movementGraph.remove([node])
                    }
                }
            }
        }
    }
    
    private func addHero(to dungeon: Dungeon, roomId: UInt) {
        let room = dungeon.roomInfo[roomId]!
               
        let roomCoords = getCoords(in: room, insetBy: 0)
        for coord in roomCoords {
            if let actor = getActor(at: coord) {
                self.entities.removeAll(where: { $0 === actor })
            }
        }

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

            let minX = Int32(max(room.coord.x - 2, 0))
            let maxX = Int32(min(room.coord.x + room.width + 2, Int(self.mapWidth - 1)))
            let minY = Int32(max(room.coord.y - 2, 0))
            let maxY = Int32(min(room.coord.y + room.height + 2, Int(self.mapHeight - 1)))
            let p1 = vector_int2(minX, midY)
            let p2 = vector_int2(maxX, midY)
            let p3 = vector_int2(midX, minY)
            let p4 = vector_int2(midX, maxY)
            let p5 = vector_int2(minX, minY)
            let p6 = vector_int2(maxX, minY)
            let p7 = vector_int2(minX, maxY)
            let p8 = vector_int2(maxX, maxY)

            for point in [p1, p2, p3, p4, p5, p6, p7, p8] {
                let coord = Coordinate(Int(point.x), Int(point.y))
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
                    let node = self.getMapNodeType(at: coord)

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
            
            let maxDecorationCount = UInt32(floor(cbrt(Float(room.area))))
            let decorationCount = arc4random_uniform(maxDecorationCount + 1)
            for _ in (0 ..< Int(decorationCount)) {
                let decorationCoord = getRandomCoord(in: room, insetBy: 1)
                if let decoration = tileset.getDecoration(coord: decorationCoord, entityFactory: self.entityFactory) {
                    let tile = self.tiles[Int(decorationCoord.y)][Int(decorationCoord.x)]
                    decoration.configure(withTile: tile)
                    self.tiles[Int(decorationCoord.y)][Int(decorationCoord.x)] = decoration
                    self.map.setType(.blocked, for: decorationCoord)
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
