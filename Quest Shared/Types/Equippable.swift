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
    case leftArm
    case rightArm
    case legs
}

protocol Equippable: Lootable {
    var equipmentSlot: EquipmentSlot { get }
}
