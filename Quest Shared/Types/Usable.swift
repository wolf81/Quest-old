//
//  Usable.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 15/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

protocol Usable: Lootable {
    var effects: [String: Any] { get }
    
    func use()
}
