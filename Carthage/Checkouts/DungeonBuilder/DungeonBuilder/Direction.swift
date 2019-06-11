//
//  Direction.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 05/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

enum Direction: Int {
    case north
    case northWest
    case northEast
    case south
    case southWest
    case southEast
    case west
    case westNorth
    case westSouth
    case east
    case eastNorth
    case eastSouth
    
    var opposite: Direction {
        switch self {
        case .north: return .south
        case .northWest: return .southEast
        case .northEast: return .southWest
        case .south: return .north
        case .southWest: return .northEast
        case .southEast: return .northWest
        case .west: return .east
        case .westNorth: return .eastSouth
        case .westSouth: return .eastNorth
        case .east: return .west
        case .eastNorth: return .westSouth
        case .eastSouth: return .westNorth
        }
    }
    
    static var cardinal: [Direction] {
        return [.north, .west, .south, .east]
    }
    
    var y: Int {
        switch self {
        case .northEast: fallthrough
        case .northWest: fallthrough
        case .eastNorth: fallthrough
        case .westNorth: fallthrough
        case .north: return -1
            
        case .southEast: fallthrough
        case .southWest: fallthrough
        case .eastSouth: fallthrough
        case .westSouth: fallthrough
        case .south: return 1
            
        default: return 0
        }
    }
    
    var x: Int {
        switch self {
        case .southWest: fallthrough
        case .northWest: fallthrough
        case .westSouth: fallthrough
        case .westNorth: fallthrough
        case .west: return -1
            
        case .southEast: fallthrough
        case .northEast: fallthrough
        case .eastNorth: fallthrough
        case .eastSouth: fallthrough
        case .east: return 1
            
        default: return 0
        }
    }
}

extension Direction: Comparable {
    static func < (lhs: Direction, rhs: Direction) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
