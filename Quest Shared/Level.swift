//
//  Level.swift
//  Quest iOS
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

struct Level {
    let width = 12
    let height = 12
    
    fileprivate let tiles: [Int]
    
    init() {
        var tiles = Array(repeatElement(0, count: width * height))
        
        for y in (0 ..< height) {
            for x in (0 ..< width) {
                let idx = Int(y * width + x)
                
                if x == 2 && y == 2 {
                    tiles[idx] = 3
                    continue
                 }
                
                if y == 0 {
                    tiles[idx] = 1
                }
                
                if x == 0 {
                    tiles[idx] = 1
                }
                
                if y == (height - 1) {
                    tiles[idx] = 1
                }
                
                if x == (width - 1) {
                    tiles[idx] = 1
                }
            }
        }
            
        self.tiles = tiles
    }
    
    func getTileAt(coord: SIMD2<Int32>) -> Int {
        let idx = Int(Int(coord.y) * width + Int(coord.x))
        
        let validRange = 0 ..< self.tiles.count
        guard validRange.contains(idx) else { return Int.min }
        
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

