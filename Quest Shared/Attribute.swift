//
//  Attribute.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

typealias Attribute = Int

extension Attribute {
    static var average: Attribute {
        return Attribute(12)
    }
    
    var bonus: Int {
        return (self - 10) / 2
    }
}
