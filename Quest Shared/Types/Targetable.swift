//
//  Targetable.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

protocol Targetable: EntityProtocol {
    var isTargetable: Bool { get }
}
