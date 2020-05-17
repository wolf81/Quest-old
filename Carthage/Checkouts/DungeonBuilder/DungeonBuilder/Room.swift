//
//  Room.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

public class Room {
    public var coord: vector_int2 { return vector_int2(Int32(i), Int32(j)) }    
    public let width: Int
    public let height: Int
    
    let i: Int
    let j: Int
    
    var doors: [Direction: [Door]] = [:]
    
    lazy var north: Int = { return self.i * 2 + 1 }()
    lazy var south: Int = { return (self.i + self.height) * 2 + 1 }()
    lazy var east: Int = { return (self.j + self.width) * 2 + 1 }()
    lazy var west: Int = { return self.j * 2 + 1 }()
//    var area: Int { return self.width * self.height }
    
    init(i: Int, j: Int, width: Int, height: Int) {
        self.i = i
        self.j = j
        self.width = width
        self.height = height
        
        for dir in Direction.cardinal {
            self.doors[dir] = []
        }
    }
}
