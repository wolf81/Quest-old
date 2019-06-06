//
//  Level.swift
//  Quest iOS
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

struct Tile: OptionSet {
    let rawValue: Int32
    
    static let floor = Tile(rawValue: 1 << 0)
    static let wall = Tile(rawValue: 1 << 1)
    static let player = Tile(rawValue: 1 << 2)
    
    static let all: Tile = [.floor, .wall, .player]
}

extension Tile: CustomStringConvertible {
    var description: String {
        var output = " "
        
        if self.contains(.player) {
            output = "P"
        } else if self.contains(.wall) {
            output = "1"
        } else if self.contains(.floor) {
            output = "0"
        } 
        
        return output
    }
}

struct Level {
    let width = 12
    let height = 8        

    let playerPosition = int2(2, 2)
    
    fileprivate let tiles: [Tile]
    
    init() {
        var tiles = Array(repeatElement(Tile.floor, count: width * height))
        
        for y in (0 ..< height) {
            for x in (0 ..< width) {
                let idx = Int(y * width + x)
                
                if y == 0 {
                    tiles[idx] = Tile.wall
                }
                
                if x == 0 {
                    tiles[idx] = Tile.wall
                }
                
                if y == (height - 1) {
                    tiles[idx] = Tile.wall
                }
                
                if x == (width - 1) {
                    tiles[idx] = Tile.wall
                }
            }
        }
            
        let idx = Int(Int(playerPosition.y) * width + Int(playerPosition.x))
        tiles[idx] = .player
        
        self.tiles = tiles
    }
    
    func getTileAt(coord: int2) -> Tile {
        let idx = Int(Int(coord.y) * width + Int(coord.x))
        return self.tiles[idx]
    }
}

extension Level : CustomStringConvertible {
    var description: String {
        var output = ""
        
        for y in (0 ..< height) {
            for x in (0 ..< width) {
                let idx = Int(y * width + x)
                
                output += "\(tiles[idx]) "
            }
            output += "\n"
        }
        
        return output
    }
}

