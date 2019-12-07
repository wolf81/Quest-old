//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Actor: Entity {
    let hitPoints: Int
    
    var damage: Int = 0
    
    private var action: Action?
        
    var isAlive: Bool {
        return (self.hitPoints - damage) > 0
    }
    
    init(json: [String : Any], hitPoints: Int) {
        self.hitPoints = hitPoints
        
        super.init(json: json)
    }
    
    required init(json: [String : Any]) {
        self.hitPoints = 1
        
        super.init(json: json)
        
        self.sprite.zPosition = 100
    }
     
    func getAction(state: Level) -> Action? {
        defer { self.action = nil }
            
        return self.action
    }
    
    func canMoveTo(coord: SIMD2<Int32>, for state: Level) -> Bool {
        let tile = state.getTileAt(coord: coord)
        return tile != 1
    }
}
