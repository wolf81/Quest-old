//
//  DungeonBuilder.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

open class DungeonBuilder {
    let configuration: Configuration
    let numberGenerator: NumberGeneratable
    
    public init(configuration: Configuration, numberGenerator: NumberGeneratable? = nil) {
        self.configuration = configuration
        self.numberGenerator = numberGenerator ?? RandomNumberGenerator()
    }
    
    public func build(name: String) -> Dungeon {
        let data = name.data(using: .utf8)!
        self.numberGenerator.seed(data: data)
        
        let size = self.configuration.dungeonSize.rawValue
        let aspectRatio = self.configuration.dungeonLayout.aspectRatio
        
        let height = Int(Float(size) * aspectRatio)
        let width = size

        let dungeon = DungeonInternal(width: width, height: height)
        applyMask(to: dungeon)
        addRooms(to: dungeon)
        openRooms(in: dungeon)
        labelRooms(in: dungeon)
        addCorridors(to: dungeon)
        clean(dungeon: dungeon)
        
        return Dungeon(dungeon: dungeon)
    }
    
    private func clean(dungeon: DungeonInternal) {
        removeDeadEnds(in: dungeon)
        fixDoors(in: dungeon)
    }
    
    private func labelRooms(in dungeon: DungeonInternal) {
        for roomId in dungeon.rooms.keys.sorted() {
            guard let room = dungeon.rooms[roomId] else { continue }
            let id = String("\(roomId)")
            let len = id.count
            let midR = Int((room.north + room.south) / 2)
            let midC = Int((room.west + room.east - len) / 2) + 1
            for i in (0 ..< len) {
                let c = id[i]
                let character = Character(String(c))
                dungeon.nodes[midR][midC + i].setLabel(character: character)
            }
        }
    }
    
    private func removeDeadEnds(in dungeon: DungeonInternal) {
        collapseTunnels(in: dungeon, closeInfo: closeEndInfo)
        
        if self.configuration.closeArcs {
            collapseTunnels(in: dungeon, closeInfo: closeArcInfo)
        }
    }
    
    private func collapseTunnels(in dungeon: DungeonInternal, closeInfo: [Direction: [CloseType: [Any]]]) {
        let deadEndRemoval = self.configuration.deadEndRemoval
        let percentage = deadEndRemoval.percentage
        
        guard percentage > 0 else { return }
        
        for i in (0 ..< dungeon.n_i) {
            let r = i * 2 + 1
            for j in (0 ..< dungeon.n_j) {
                let c = j * 2 + 1
                let node = dungeon.nodes[r][c]
                
                if node.intersection(.openspace).isEmpty == false, node.contains(.stairs) {
                    continue
                }
                
                if (deadEndRemoval == .all) || (self.numberGenerator.next(maxValue: 100) < percentage) {
                    let position = Coordinate(r, c)
                    collapseTunnel(in: dungeon, position: position, directionCloseInfo: closeInfo)
                }
            }
        }
    }
    
    private func collapseTunnel(in dungeon: DungeonInternal, position: Coordinate, directionCloseInfo: [Direction: [CloseType: [Any]]]) {
        if dungeon[position.x, position.y].isDisjoint(with: .openspace) {
            return
        }
        
        for direction in directionCloseInfo.keys {
            let directionCloseEndInfo = directionCloseInfo[direction]!
            
            if checkTunnel(in: dungeon, position: position, closeInfo: directionCloseEndInfo) {
                if let closeInfo = directionCloseEndInfo[.close] as? [[Int]] {
                    for closePosition in closeInfo {
                        let r = position.x + closePosition[0]
                        let c = position.y + closePosition[1]
                        dungeon.nodes[r][c] = .nothing
                    }
                }
                
                if let openInfo = directionCloseEndInfo[.open] as? [Int] {
                    let r = position.x + openInfo[0]
                    let c = position.y + openInfo[1]
                    dungeon.nodes[r][c].insert(.corridor)
                }
                
                if let recurseInfo = directionCloseEndInfo[.recurse] as? [Int] {
                    let r = position.x + recurseInfo[0]
                    let c = position.y + recurseInfo[1]
                    if !(0 ..< dungeon.height).contains(r) || !(0 ..< dungeon.width).contains(c) {
                        continue
                    }

                    collapseTunnel(in: dungeon, position: Coordinate(r, c), directionCloseInfo: directionCloseInfo)
                }
            }
        }
    }
    
    private func checkTunnel(in dungeon: DungeonInternal, position: Coordinate, closeInfo: [CloseType: [Any]]) -> Bool {
        if let corridorInfo = closeInfo[.corridor] as? [[Int]] {
            for corridorPosition in corridorInfo {
                let r = position.x + corridorPosition[0]
                let c = position.y + corridorPosition[1]
                
                if dungeon.nodes[r][c].isDisjoint(with: .corridor) {
                    return false
                }
            }
        }
        
        if let walledInfo = closeInfo[.walled] as? [[Int]] {
            for corridorPosition in walledInfo {
                let r = position.x + corridorPosition[0]
                let c = position.y + corridorPosition[1]
                
                guard dungeon.nodes[r][c].isDisjoint(with: .openspace) else {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func applyMask(to dungeon: DungeonInternal) {
        guard let mask = self.configuration.dungeonLayout.mask else {
            return
        }
        
        let mr = Float(mask.count) / Float(dungeon.height)
        let mc = Float(mask[0].count) / Float(dungeon.width)
        
        for r in 0 ..< dungeon.height {
            let rv = mask[Int(Float(r) * mr)]
            for cv in 0 ..< dungeon.width {
                if rv[Int(Float(cv) * mc)] == 0 {
                    dungeon.nodes[r][cv] = .blocked
                }
            }
        }
    }
    
    private func addRooms(to dungeon: DungeonInternal) {
        switch self.configuration.roomLayout {
        case .dense: addDenseRooms(to: dungeon)
        default: addScatteredRooms(to: dungeon)
        }
    }
    
    private func addCorridors(to dungeon: DungeonInternal) {
        for i in (0 ..< dungeon.n_i) {
            let r = i * 2 + 1
            
            for j in (0 ..< dungeon.n_j) {
                let c = j * 2 + 1
                
                guard dungeon.nodes[r][c].isDisjoint(with: .corridor) else {
                    continue
                }
                
                makeTunnel(in: dungeon, position: Coordinate(i, j))
            }
        }
    }
    
    private func openRooms(in dungeon: DungeonInternal) {
        for roomId in dungeon.rooms.keys.sorted() {
            openRoom(in: dungeon, roomId: roomId)
        }
    }
    
    private func openRoom(in dungeon: DungeonInternal, roomId: UInt) {
        var sills = doorSills(for: dungeon, roomId: roomId)

        guard let room = dungeon.rooms[roomId], sills.count > 0 else {
            return
        }
        
        let openCount = allocOpens(for: dungeon, room: room)
        
        for _ in (0 ..< openCount) {
            guard sills.count > 0 else {
                return
            }
            
            let sillIdx = self.numberGenerator.next(maxValue: sills.count)
            let sill = sills.remove(at: sillIdx)
            let i = sill.door_r
            let j = sill.door_c
            guard dungeon.nodes[i][j].isDisjoint(with: .doorspace) else {
                continue
            }
            
            if let out_id = sill.out_id {
                let ids = [roomId, out_id].sorted()
                let connection = "\(ids[0]),\(ids[1])"
                if dungeon.connections.contains(connection) == false {
                    openDoor(for: dungeon, room: room, sill: sill)
                    dungeon.connections.append(connection)
                }
            } else {
                openDoor(for: dungeon, room: room, sill: sill)
            }
        }
    }
    
    private func openDoor(for dungeon: DungeonInternal, room: Room, sill: Sill) {
        for n in (0 ..< 3) {
            let r = sill.r + sill.direction.y * n
            let c = sill.c + sill.direction.x * n
            dungeon.nodes[r][c].remove(.perimeter)
            dungeon.nodes[r][c].insert(.entrance)
        }

        let door = Door(row: sill.door_r, col: sill.door_c, out_id: sill.out_id)
        room.doors[sill.direction]?.append(door)
        
        dungeon.nodes[sill.door_r][sill.door_c] = doorType()
    }

    private func fixDoors(in dungeon: DungeonInternal) {
        var fixed: [String] = []
        
        for roomKey in dungeon.rooms.keys.sorted() {
            guard let room = dungeon.rooms[roomKey] else {
                continue
            }
            
            for direction in room.doors.keys.sorted() {
                guard let doors = room.doors[direction], doors.count > 0 else {
                    continue
                }
                
                var fixedDoors: [Door] = []
                for door in doors {
                    let node = dungeon.nodes[door.row][door.col]
                    guard node.intersection(.openspace).isEmpty == false else {
                        dungeon.nodes[door.row][door.col] = []
                        continue
                    }

                    let doorKey = "\(door.row).\(door.col)"

                    if fixed.contains(doorKey) {
                        fixedDoors.append(door)
                    } else {
                        if let out_id = door.out_id {
                            let out_dir = direction.opposite
                            dungeon.rooms[out_id]?.doors[out_dir]?.append(door)
                        }
                        fixedDoors.append(door)
                        fixed.append(doorKey)
                    }
                }
                
                if fixedDoors.count > 0 {
                    dungeon.rooms[roomKey]?.doors[direction] = fixedDoors
                } else {
                    dungeon.rooms[roomKey]?.doors[direction]?.forEach({ (door) in
                        dungeon.nodes[door.row][door.col] = .perimeter
                    })
                    dungeon.rooms[roomKey]?.doors.removeValue(forKey: direction)
                }
            }
        }
    }

    private func doorType() -> Node {
        switch self.numberGenerator.next(maxValue: 110) {
        case ..<15: return .arch
        case ..<60: return .door
        case ..<75: return .locked
        case ..<90: return .trapped
        case ..<100: return .secret
        default: return .portcullis
        }
    }
    
    private func allocOpens(for dungeon: DungeonInternal, room: Room) -> Int {
        let openCount = Int(sqrt(Double(room.width + 1) * Double(room.height + 1)))
        return openCount + numberGenerator.next(maxValue: openCount)
    }
    
    private func doorSills(for dungeon: DungeonInternal, roomId: UInt) -> [Sill] {
        var sills: [Sill] = []
        
        guard let room = dungeon.rooms[roomId] else {
            return []
        }
        
        if room.north >= 3 {
            for c in stride(from: room.west, to: room.east, by: 2) {
                let position = Coordinate(room.north, c)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .north) {
                    sills.append(sill)
                }
            }
        }
        
        if room.south <= (dungeon.height - 3) {
            for c in stride(from: room.west, to: room.east, by: 2) {
                let position = Coordinate(room.south, c)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .south) {
                    sills.append(sill)
                }
            }
        }

        if room.west >= 3 {
            for r in stride(from: room.north, to: room.south, by: 2) {
                let position = Coordinate(r, room.west)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .west) {
                    sills.append(sill)
                }
            }
        }
        
        if room.east <= (dungeon.width - 3) {
            for r in stride(from: room.north, to: room.south, by: 2) {
                let position = Coordinate(r, room.east)
                if let sill = checkSill(for: dungeon, roomId: roomId, position: position, direction: .east) {
                    sills.append(sill)
                }
            }
        }

        return sills
    }
    
    private func checkSill(for dungeon: DungeonInternal, roomId: UInt, position: Coordinate, direction: Direction) -> Sill? {
        let door_r = position.x + direction.y
        let door_c = position.y + direction.x
        let door_cell = dungeon.nodes[door_r][door_c]
        
        guard door_cell.contains(.perimeter), door_cell.isDisjoint(with: .blockDoor) else {
            return nil
        }
        
        let out_r = door_r + direction.y
        let out_c = door_c + direction.x
        let out_cell = dungeon.nodes[out_r][out_c]
        
        guard out_cell.isDisjoint(with: .blocked) else {
            return nil
        }
                
        if out_cell.roomId == roomId {
            return nil
        }
        
        return Sill(
            r: position.x,
            c: position.y,
            direction: direction,
            door_r: door_r,
            door_c: door_c,
            out_id: out_cell.roomId > 0 ? out_cell.roomId : nil
        )
    }
    
    private func makeTunnel(in dungeon: DungeonInternal, position: Coordinate, with direction: Direction? = nil) {
        let randomDirections = tunnelDirections(with: direction)
        
        for randomDirection in randomDirections {
            if openTunnel(in: dungeon, position: position, direction: randomDirection) {
                let r = position.x + randomDirection.y
                let c = position.y + randomDirection.x
                makeTunnel(in: dungeon, position: Coordinate(r, c), with: randomDirection)
            }
        }
    }
    
    private func openTunnel(in dungeon: DungeonInternal, position: Coordinate, direction: Direction) -> Bool {
        let r1 = position.x * 2 + 1
        let c1 = position.y * 2 + 1
        let r2 = (position.x + direction.y) * 2 + 1
        let c2 = (position.y + direction.x) * 2 + 1
        let rMid = (r1 + r2) / 2
        let cMid = (c1 + c2) / 2
        
        let origin = Coordinate(rMid, cMid)
        let destination = Coordinate(r2, c2)
        if soundTunnel(in: dungeon, origin: origin, destination: destination) {
            return delveTunnel(in: dungeon, origin: Coordinate(r1, c1), destination: destination)
        }
        
        return false
    }
    
    private func delveTunnel(in dungeon: DungeonInternal, origin: Coordinate, destination: Coordinate) -> Bool {
        let b = [origin.x, destination.x].sorted()
        let c = [origin.y, destination.y].sorted()
        
        for e in b[0] ... b[1] {
            for d in c[0] ... c[1] {
                dungeon.nodes[e][d].remove(.entrance)
                dungeon.nodes[e][d].insert(.corridor)
            }
        }
        
        return true
    }
    
    private func soundTunnel(in dungeon: DungeonInternal, origin: Coordinate, destination: Coordinate) -> Bool {
        guard (0 ..< dungeon.height).contains(destination.x) else { return false }
        guard (0 ..< dungeon.width).contains(destination.y) else { return false }
        
        let rowIdxs = [origin.x, destination.x].sorted()
        let colIdxs = [origin.y, destination.y].sorted()
        
        for r in rowIdxs[0] ... rowIdxs[1] {
            for c in colIdxs[0] ... colIdxs[1] {
                let cell = dungeon.nodes[r][c]                
                guard cell.intersection(.blockCorr).isEmpty else {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func tunnelDirections(with direction: Direction?) -> [Direction] {
        var shuffledDirections = shuffle(items: Direction.cardinal)

        if let direction = direction {
            let randomPercent = self.numberGenerator.next(maxValue: 100)
            if  randomPercent < self.configuration.corridorLayout.straightPercent {
                shuffledDirections.insert(direction, at: 0)
            }
        }
        return shuffledDirections
    }
    
    private func shuffle<T: Comparable>(items: [T]) -> [T] {
        var shuffledItems = items
        
        for i in (0 ..< shuffledItems.count).reversed() {
            let j = self.numberGenerator.next(maxValue: i + 1)
            let k = shuffledItems[i]
            shuffledItems[i] = shuffledItems[j]
            shuffledItems[j] = k
        }
        
        return shuffledItems
    }
    
    private func addDenseRooms(to dungeon: DungeonInternal) {
        for i in 0 ..< dungeon.n_i {
            let r = i * 2 + 1
            for j in 0 ..< dungeon.n_j {
                let c = j * 2 + 1
                
                guard dungeon.nodes[r][c].isDisjoint(with: .room) else {
                    continue
                }
                
                guard (i != 0 && j != 0) && numberGenerator.next(maxValue: 2) != 0 else {
                    continue
                }

                emplaceRoom(
                    in: dungeon,
                    roomSize: self.configuration.roomSize,
                    position: Coordinate(i, j)
                )
            }
        }
    }
    
    private func addScatteredRooms(to dungeon: DungeonInternal) {
        var roomCount = allocateRooms(for: dungeon, roomSize: self.configuration.roomSize)
        
        for _ in (0 ..< roomCount) {
            emplaceRoom(in: dungeon, roomSize: self.configuration.roomSize)
        }
        
        if self.configuration.roomSize.isHuge {
            roomCount = allocateRooms(for: dungeon, roomSize: .medium)
            for _ in (0 ..< roomCount) {
                emplaceRoom(in: dungeon, roomSize: .medium)
            }
        }
    }
    
    private func emplaceRoom(in dungeon: DungeonInternal, roomSize: RoomSize, position: Coordinate = .zero) {
        if dungeon.rooms.count > 999 {
            return
        }
        
        let room = makeRoom(for: dungeon, roomSize: roomSize, position: position)

        let r1 = room.i * 2 + 1
        let c1 = room.j * 2 + 1
        let r2 = (room.i + room.height) * 2 + 1
        let c2 = (room.j + room.width) * 2 + 1
        
        guard
            (r1 > 0 && r2 < dungeon.maxRowIndex) &&
            (c1 > 0 && c2 < dungeon.maxColumnIndex) else {
            return
        }
        
        guard
            let hitInfo = soundRoom(for: dungeon, r1: r1, c1: c1, r2: r2, c2: c2),
            hitInfo.count == 0 else {
            return
        }
        
        let roomId = UInt(dungeon.rooms.count + 1)
        
        for r in (r1 ... r2) {
            for c in (c1 ... c2) {
                var node = dungeon.nodes[r][c]
                
                if node.contains(.entrance) {
                    node.remove(.espace)
                } else if node.contains(.perimeter) {
                    node.remove(.perimeter)
                }
                
                node.setRoom(roomId: roomId)
                dungeon.nodes[r][c] = node
            }
        }
        
        // TODO: Add room data to rooms array of dungeon
        
        for r in (r1 - 1 ... r2 + 1) {
            var node = dungeon.nodes[r][c1 - 1]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r][c1 - 1] = node
            
            node = dungeon.nodes[r][c2 + 1]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r][c2 + 1] = node
        }

        for c in (c1 - 1 ... c2 + 1) {
            var node = dungeon.nodes[r1 - 1][c]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r1 - 1][c] = node
            
            node = dungeon.nodes[r2 + 1][c]
            if node.contains([.room, .entrance]) == false {
                node.insert(.perimeter)
            }
            dungeon.nodes[r2 + 1][c] = node
        }
        
        dungeon.rooms[roomId] = room
    }
    
    private func makeRoom(for dungeon: DungeonInternal, roomSize: RoomSize, position: Coordinate) -> Room {
        let radixBase = roomSize.radix
        let size = roomSize.size
        
        var height: Int = 0
        var width: Int = 0

        var i = position.x
        var j = position.y
        
        if i != 0 {
            let radix = min(max(dungeon.n_i - size - position.x, 0), radixBase)
            height = self.numberGenerator.next(maxValue: radix) + size
        } else {
            height = self.numberGenerator.next(maxValue: radixBase) + size
        }
        
        if j != 0 {
            let radix = min(max(dungeon.n_j - size - position.y, 0), radixBase)
            width = self.numberGenerator.next(maxValue: radix) + size
        } else {
            width = self.numberGenerator.next(maxValue: radixBase) + size
        }
        
        if i == 0 {
            i = self.numberGenerator.next(maxValue: dungeon.n_i - height)
        }
        
        if j == 0 {
            j = self.numberGenerator.next(maxValue: dungeon.n_j - width)
        }

        return Room(i: i, j: j, width: width, height: height)
    }
    
    private func soundRoom(for dungeon: DungeonInternal, r1: Int, c1: Int, r2: Int, c2: Int) -> [UInt: UInt]? {
        var hitInfo: [UInt: UInt] = [:]
        
        for r in (r1 ... r2) {
            for c in (c1 ... c2) {
                let node = dungeon.nodes[r][c]
                
                if node.contains(.blocked) {
                    return nil
                }
                
                if node.contains(.room) {
                    let hitCount = hitInfo[node.roomId] ?? 0
                    hitInfo[node.roomId] = hitCount + 1
                }
            }
        }
        
        return hitInfo
    }
    
    private func allocateRooms(for dungeon: DungeonInternal, roomSize: RoomSize) -> Int {
        let size = roomSize.size
        let radix = roomSize.radix
        let dungeonArea = dungeon.width * dungeon.height
        let roomArea = (size + radix + 1) ^ 2
        var roomCount = Int(dungeonArea / roomArea) * 2
        if self.configuration.roomLayout == .sparse {
            roomCount /= 13
        }
        return roomCount
    }
}
