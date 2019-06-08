//
//  Actionable.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

protocol Actionable where Self: Creature {
    func perform(action: Action, completion: @escaping () -> Void)
}
