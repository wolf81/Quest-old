//
//  IdentifierGenerator.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class IdentifierGenerator {
    private static var id: UInt = 0
    
    static func generateNext() -> UInt {
        self.id = (self.id + 1) % (UInt.max - 1)
        
        print("id: \(self.id)")
        return self.id
    }
}
