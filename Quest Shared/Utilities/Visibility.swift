//
//  Visibility.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 22/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

protocol Visibility {
    func compute(origin: vector_int2, rangeLimit: Int32)
}

final public class RaycastVisibility: Visibility {
    private let mapSize: CGSize
    private let blocksLight: (Int32, Int32) -> (Bool)
    private let setVisible: (Int32, Int32) -> ()
    private let getDistance: (Int32, Int32, Int32, Int32) -> Int
    
    init(mapSize: CGSize,
         blocksLight: @escaping (Int32, Int32) -> (Bool),
         setVisible: @escaping (Int32, Int32) -> (),
         getDistance: @escaping (Int32, Int32, Int32, Int32) -> Int)  {
        self.mapSize = mapSize
        self.blocksLight = blocksLight
        self.setVisible = setVisible
        self.getDistance = getDistance
    }
    
    func compute(origin: vector_int2, rangeLimit: Int32) {
        setVisible(origin.x, origin.y)
        
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
    
    /*
     int xDiff = x2 - origin.X, yDiff = y2 - origin.Y, xLen = Math.Abs(xDiff), yLen = Math.Abs(yDiff);
     int xInc = Math.Sign(xDiff), yInc = Math.Sign(yDiff)<<16, index = (origin.Y<<16) + origin.X;
     if(xLen < yLen) // make sure we walk along the long axis
     {
       Utility.Swap(ref xLen, ref yLen);
       Utility.Swap(ref xInc, ref yInc);
     }
     int errorInc = yLen*2, error = -xLen, errorReset = xLen*2;
     while(--xLen >= 0) // skip the first point (the origin) since it's always visible and should never stop rays
     {
       index += xInc; // advance down the long axis (could be X or Y)
       error += errorInc;
       if(error > 0) { error -= errorReset; index += yInc; }
       int x = index & 0xFFFF, y = index >> 16;
       if(rangeLimit >= 0 && GetDistance(origin.X, origin.Y, x, y) > rangeLimit) break;
       SetVisible(x, y);
       if(BlocksLight(x, y)) break;
     }
     */
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
            if rangeLimit >= 0 && getDistance(origin.x, origin.y, x, y) > rangeLimit {
                break
            }
            setVisible(x, y)
            if blocksLight(x, y) { break }
        }
    }
}

final public class ShadowcastVisibility: Visibility {
    func compute(origin: vector_int2, rangeLimit: Int32) {
        
    }
}
