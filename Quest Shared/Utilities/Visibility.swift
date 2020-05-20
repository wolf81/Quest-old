//
//  Visibility.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 22/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import simd

protocol Visibility {
    func compute(origin: vector_int2, rangeLimit: Int32)
}

final public class RaycastVisibility: Visibility {
    private let mapSize: CGSize
    private let blocksLight: (vector_int2) -> (Bool)
    private let setVisible: (vector_int2) -> ()
    private let getDistance: (vector_int2, vector_int2) -> Int
    
    init(mapSize: CGSize,
         blocksLight: @escaping (vector_int2) -> (Bool),
         setVisible: @escaping (vector_int2) -> (),
         getDistance: @escaping (vector_int2, vector_int2) -> Int)  {
        self.mapSize = mapSize
        self.blocksLight = blocksLight
        self.setVisible = setVisible
        self.getDistance = getDistance
    }
    
    func compute(origin: vector_int2, rangeLimit: Int32) {
        setVisible(origin)
        
        if rangeLimit != 0 {
            let area = CGRect(x: 0, y: 0, width: mapSize.width, height: mapSize.height)
            if rangeLimit >= 0 {
                area.intersects(CGRect(x: (Int)(origin.x - rangeLimit), y: (Int)(origin.y - rangeLimit), width: Int(rangeLimit * 2 + 1), height: Int(rangeLimit * 2 + 1)))
            }

            let xRange = Int32(area.minX) ..< Int32(area.maxX)
            for x in xRange {
                traceLine(origin: origin, x2: x, y2: Int32(area.maxY), rangeLimit: rangeLimit)
                traceLine(origin: origin, x2: x, y2: Int32(area.minY) - 1, rangeLimit: rangeLimit)
            }
            
            let yRange = Int32(area.minY - 1) ..< Int32(area.maxY + 1)
            for y in yRange.reversed() {
                traceLine(origin: origin, x2: Int32(area.minX), y2: y, rangeLimit: rangeLimit)
                traceLine(origin: origin, x2: Int32(area.maxX) - 1, y2: y, rangeLimit: rangeLimit)
            }
        }
    }
    
    private func traceLine(origin: vector_int2, x2: Int32, y2: Int32, rangeLimit: Int32) {
        let xDiff = x2 - origin.x
        let yDiff = y2 - origin.y
        var xLen = abs(xDiff)
        var yLen = abs(yDiff)
        var xInc = xDiff.signum()
        var yInc = yDiff.signum() << 16
        var index = (origin.y << 16) + origin.x
        if (xLen < yLen) {
            (xLen, yLen) = (yLen, xLen)
            (xInc, yInc) = (yInc, xInc)
        }
        let errorInc = yLen * 2
        var error = -(xLen)
        let errorReset = xLen * 2
        xLen -= 1
        while (xLen >= 0) {
            index += xInc
            error += errorInc
            if (error > 0) {
                error -= errorReset
                index += yInc
            }
            let x = index & 0xffff
            let y = index >> 16
            let destination = vector_int2(x, y)
            if rangeLimit >= 0 && getDistance(origin, destination) > rangeLimit {
                break
            }
            setVisible(destination)
            if blocksLight(destination) { break }
        }
    }
}
