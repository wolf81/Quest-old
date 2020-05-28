//
//  Direction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import simd

enum Direction {
    case north
    case south
    case west
    case east
    case northWest
    case northEast
    case southWest
    case southEast
    
    var isCardinal: Bool {
        let cardinalDirections: [Direction] = [.north, .west, .south, .east]
        return cardinalDirections.contains(self)
    }

    /// A direction is based on an x-value and y-value, e.g. up has an x-value of 0 and y-value of 1, down has an x-value of 0 and y-value of -1, etc...
    var coord: vector_int2 {
        switch self {
        case .north: return vector_int2(0, 1)
        case .south: return vector_int2(0, -1)
        case .west: return vector_int2(-1, 0)
        case .east: return vector_int2(1, 0)
        case .northWest: return vector_int2(-1, 1)
        case .northEast: return vector_int2(1, 1)
        case .southWest: return vector_int2(-1, -1)
        case .southEast: return vector_int2(1, -1)
        }
    }
    
    var adjacentDirections: [Direction] {
        switch self {
        case .east: return [.northEast, .southEast]
        case .west: return [.northWest, .southWest]
        case .north: return [.northWest, .northEast]
        case .south: return [.southWest, .southEast]
        case .northWest: return [.north, .west]
        case .northEast: return [.north, .east]
        case .southEast: return [.south, .east]
        case .southWest: return [.south, .west]
        }
    }
    
    static func relative(from fromCoord: vector_int2, to toCoord: vector_int2) -> Direction {
        let y: Int32 = fromCoord.y == toCoord.y ? 0 : (fromCoord.y > toCoord.y ? -1 : 1)
        let x: Int32 = fromCoord.x == toCoord.x ? 0 : (fromCoord.x > toCoord.x ? -1 : 1)
        return Direction(rawValue: vector_int2(x, y))
    }
    
    init(rawValue: vector_int2) {
        switch rawValue {
        case vector_int2(0, 1): self = .north
        case vector_int2(0, -1): self = .south
        case vector_int2(-1, 0): self = .west
        case vector_int2(1, 0): self = .east
        case vector_int2(-1, 1): self = .northWest
        case vector_int2(1, 1): self = .northEast
        case vector_int2(-1, -1): self = .southWest
        case vector_int2(1, -1): self = .southEast
        default: fatalError()
        }
    }
}
