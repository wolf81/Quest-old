//
//  Node.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public struct Node: OptionSet {
    public var rawValue: UInt
    
    // MARK: - singular values
    public static let nothing = Node(rawValue: 0)
    public static let blocked = Node(rawValue: 1 << 0)
    public static let room = Node(rawValue: 1 << 1)
    public static let corridor = Node(rawValue: 1 << 2)
    public static let perimeter = Node(rawValue: 1 << 3)
    public static let entrance = Node(rawValue: 1 << 4)
    public static let roomId = Node(rawValue: (1 << 16) - (1 << 6))
    public static let arch = Node(rawValue: 1 << 16)
    public static let door = Node(rawValue: 1 << 17)
    public static let locked = Node(rawValue: 1 << 18)
    public static let trapped = Node(rawValue: 1 << 19)
    public static let secret = Node(rawValue: 1 << 20)
    public static let portcullis = Node(rawValue: 1 << 21)
    public static let stairDown = Node(rawValue: 1 << 22)
    public static let stairUp = Node(rawValue: 1 << 23)
    public static let label = Node(rawValue: (1 << 32) - (1 << 24))
    
    // MARK: - compound values
    public static let openspace: Node = [.room, .corridor]
    public static let doorspace: Node = [.arch, .door, .locked, .trapped, .secret, .portcullis]
    public static let espace: Node = [.entrance, .doorspace, .label]
    public static let stairs: Node = [.stairUp, .stairDown]
    public static let blockRoom: Node = [.blocked, .room]
    public static let blockCorr: Node = [.blocked, .perimeter, .corridor]
    public static let blockDoor: Node = [.blocked, .doorspace]
    
    // MARK: - Constructors
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    // MARK: - Public
    
    public var roomId: UInt {
        get {
            return (self.rawValue & Node.roomId.rawValue) >> 6
        }
    }
    
    public var label: String? {
        get {
            let value = UInt8(self.rawValue >> 24 & 255)
            let scalar = UnicodeScalar(value)
            return value != 0 ? String(scalar) : nil
        }
    }
    
    /// Mark the node as containing a room and set the room id.
    ///
    /// - Parameter roomId: The id of the room.
    mutating func setRoom(roomId: UInt) {
        self.insert(.room)
        
        var value = self.rawValue

        // clear old room id
        value = value & 0b1111_1111_1111_1111_0000_0000_0011_1111
        
        // set the new room id
        value |= (Node.roomId.rawValue & (roomId << 6))
        
        // update the node
        self = Node(rawValue: value)
    }
    
    mutating func setLabel(character: Character) {
        var value = self.rawValue
        
        // clear old label
        value = value & 0b0000_0000_1111_1111_1111_1111_1111_1111
        
        // TODO: perhaps throw error for invalid chars?
        if let char = character.unicodeScalars.first, char.isASCII {
            value |= UInt(char.value) << 24
        }
        
        self = Node(rawValue: value)
    }
}

// MARK: - Equatable

extension Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Hashable

extension Node: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
