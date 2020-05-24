//
//  Equippable.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 11/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

enum EquipmentSlot {
    case head
    case chest
    case mainhand
    case offhand
    case legs
    case ring
    case feet
    case waist
}

protocol Equippable: Lootable {
    var equipmentSlot: EquipmentSlot { get }
    
    var effects: [Effect] { get }
}
