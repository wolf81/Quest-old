//
//  Potion.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 15/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class Potion: Entity & Usable {
    var effects: [String : Any] = [:]
    
    func use() {
        print("use")
    }
}
