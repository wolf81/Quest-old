//
//  Functions.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 23/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import simd

struct Functions {
    // Based on: https://github.com/RockLobster/Bresenham-Swift/blob/master/Bresenham/Bresenham.swift
    static func coordsBetween(_ start: vector_int2, _ end: vector_int2) -> [vector_int2] {
        var p1 = start
        var p2 = end
        
        let isSteep = abs(end.y - start.y) > abs(end.x - start.x)
        if isSteep {
            p1 = vector_int2(p1.y, p1.x)
            p2 = vector_int2(p2.y, p2.x)
        }
        
        if p2.x < p1.x {
            (p1, p2) = (p2, p1)
        }
        
        return internalCoordsBetween(p1, p2, isSteep: isSteep)
    }
        
    /// From a position and radius return a range that is constrained to another range, e.g. if we wanted to get a range of numbers with
    /// origin 5 and radius 3 and a constrained to the range [4 ... 10], this function would return the following range [4, 5, 6, 7, 8]
    /// - Parameters:
    ///   - origin: The start position for the range calculation
    ///   - radius: The radius for which we want to return a new range
    ///   - range: A range that is used to constrain the values returned to some minimum and maximum value
    static func getRange<T: BinaryInteger>(origin: T, radius: T, constrainedTo range: Range<T>) -> Range<T> {
        let minValue = max(origin - radius, range.lowerBound)
        let maxValue = min(origin + radius + 1, range.upperBound)
        return T(minValue) ..< T(maxValue)
    }
    
    // MARK: - Private
    
    private static func internalCoordsBetween(_ start: vector_int2, _ end: vector_int2, isSteep: Bool) -> [vector_int2] {
        let dx = end.x - start.x
        let dy = end.y - start.y
                
        let yStep: Int32 = dy >= 0 ? 1 : -1
        let slope = abs(Float(dy) / Float(dx))
        var error: Float = 0
        let x = start.x
        var y = start.y
        
        var coords: [vector_int2] = [isSteep ? vector_int2(y, x) : vector_int2(x, y)]
        for x in (x + 1) ... (end.x) {
            error += slope
            if error >= 0.5 {
                y += yStep
                error -= 1
            }
            coords.append(isSteep ? vector_int2(y, x) : vector_int2(x, y))
        }

        return coords
    }
}
