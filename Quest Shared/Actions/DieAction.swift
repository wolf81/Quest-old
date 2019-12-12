//
//  DieAction.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 12/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class DieAction: Action {
    override var message: String { return "\(self.actor.name) (HP: \(self.actor.hitPoints.current) / \(self.actor.hitPoints.base)): Dies"}
    
    override func perform(completion: @escaping () -> Void) -> Bool {
        completion()
        
        return true
    }
}
