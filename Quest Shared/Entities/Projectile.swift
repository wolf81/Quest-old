//
//  Projectile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 23/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class Projectile: Entity {
    private lazy var soundInfo: [SoundType: [String]] = {
        guard let soundInfo = self.json["sounds"] as? [String: [String]] else { return [:] }
            
        var result: [SoundType: [String]] = [:]
        for (typeName, soundNames) in soundInfo {
            let soundType = SoundType(rawValue: typeName)!
            result[soundType] = soundNames
        }

        return result
    }()

    required init(json: [String : Any], entityFactory: EntityFactory) {
        super.init(json: json, entityFactory: entityFactory)
    }
    
    func configureSprite(origin: vector_int2, target: vector_int2) {
        let direction = Direction.relative(from: origin, to: target)                
        let name = String(describing: direction)
        let spriteInfo = self.json["sprite"] as! [String: String]
        let spriteName = spriteInfo[name]!        
        self.sprite = Entity.loadSprite(type: self, spriteName: spriteName)
    }
    
    func playSound(_ type: SoundType, on node: SKNode) {
        guard let sounds = self.soundInfo[type] else { return }
        
        let index = arc4random_uniform(UInt32(sounds.count))
        let sound = sounds[Int(index)]
                
        let play = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        node.run(play)
    }
}
