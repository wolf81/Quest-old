//
//  Doors.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 07/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public enum Doors: String {
    case none
    case basic
    case secure
    case standard
    case deathtrap
    
    var table: [Node: Range<Int>] {
        switch self {
        case .none: return [
            .arch: (1 ..< 15)
            ]
        case .basic: return [
            .arch: (1 ..< 15),
            .door: (16 ..< 60)
            ]
        case .secure: return [
            .arch: (1 ..< 15),
            .door: (16 ..< 60),
            .locked: (61 ..< 75)
            ]
        case .standard: return [
            .arch: (1 ..< 15),
            .door: (16 ..< 60),
            .locked: (61 ..< 75),
            .trapped: (76 ..< 90),
            .secret: (91 ..< 100),
            .portcullis: (101 ..< 110)
            ]
        case .deathtrap: return [
            .arch: (1 ..< 15),
            .trapped: (16 ..< 30),
            .secret: (31 ..< 40),
            ]
        }
    }
}
