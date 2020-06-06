//
//  Trap.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 29/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

enum TrapState {
    case hidden // show default tile texture
    case discovered // show the trap plate texture
    case triggered // show the trap
    
    var isActive: Bool { [.hidden, .discovered].contains(self) }
}

class Trap: TileProtocol {
    private lazy var soundInfo: [SoundType: [String]] = {
        guard let soundInfo = self.json["sounds"] as? [String: [String]] else { return [:] }
            
        var result: [SoundType: [String]] = [:]
        for (typeName, soundNames) in soundInfo {
            let soundType = SoundType(rawValue: typeName)!
            result[soundType] = soundNames
        }

        return result
    }()

    private let json: [String: Any]

    var didExplore: Bool = false
    
    private var state: TrapState = .hidden {
        didSet {
            updateForTrapState()
        }
    }
        
    var searchDifficultyClass: Int
    
    var disableDifficultyClass: Int
    
    var isActive: Bool { self.state.isActive }
    
    lazy var name: String = { self.json["name"] as! String }()
    
    var sprite: SKSpriteNode = SKSpriteNode(color: .clear, size: Constants.tileSize)
        
    var coord: vector_int2 = vector_int2.zero
        
    let attack: Int
    
    let damageDie: HitDie

    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.json = json
                
        self.attack = json["AT"] as? Int ?? 0
        let damage = json["damage"] as! String
        self.damageDie = HitDie(rawValue: damage)!
        
        let dc = json["dc"] as! [String: Int]
        self.searchDifficultyClass = dc["search"] ?? 20
        self.disableDifficultyClass = dc["disable"] ?? 20
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        self.json = json
        self.coord = coord
        
        self.attack = json["AT"] as? Int ?? 0
        let damage = json["damage"] as! String
        self.damageDie = HitDie(rawValue: damage)!
        
        let dc = json["dc"] as! [String: Int]
        self.searchDifficultyClass = dc["search"] ?? 20
        self.disableDifficultyClass = dc["disable"] ?? 20
    }

    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        return copyInternal(coord: coord, entityFactory: entityFactory)
    }
    
    private func copyInternal<T: Trap>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        let entity = T(json: self.json, entityFactory: entityFactory, coord: coord)
        return entity
    }
    
    func search(hero: Hero) -> Bool {
        let bonus = hero.attributes.mind + hero.skills.subterfuge + hero.level / 2
        let roll = HitDie.d20(1, bonus).randomValue

        print("search trap: \(roll) vs \(self.searchDifficultyClass)")

        let trapFound = roll >= self.searchDifficultyClass
        if trapFound {
            self.state = .discovered
            self.updateForTrapState()
        }
        
        return trapFound
    }
    
    func disable(hero: Hero) -> Bool {
        return false
    }
    
    func trigger(actor: Actor) -> Int {
        self.state = .triggered
        
        let attackDie = HitDie.d20(1, 0)

        guard attackDie.randomValue >= self.attack else { return 0 }
        
        let damage = self.damageDie.randomValue
        actor.reduceHealth(with: damage)
        
        return damage
    }
    
    func disable() -> Bool {
        return false
    }
    
    func configure(withTile tile: TileProtocol) {
        self.sprite = tile.sprite.copy() as! SKSpriteNode
        self.state = .hidden
        self.coord = tile.coord
        /*
        let spriteJson = self.json["sprite"]
        var spriteName: String
        
        if let spriteNames = spriteJson as? [String] {
            let spriteIdx = Int(arc4random_uniform(UInt32(spriteNames.count)))
            spriteName = spriteNames[spriteIdx]
        } else {
            spriteName = spriteJson as! String
        }
                
        let decorationSprite = Entity.loadSprite(type: self, spriteName: spriteName)
        let sprite = tile.sprite.copy() as! SKSpriteNode
        sprite.addChild(decorationSprite)
        self.sprite = sprite
     */
    }
    
    private func updateForTrapState() {
        switch self.state {
        case .hidden: self.sprite.removeAllChildren()
        case .discovered:
            self.sprite.removeAllChildren()
            let trapSprite = Entity.loadSprite(type: self, spriteName: "pressure_plate")
            self.sprite.addChild(trapSprite)
        case .triggered:
            self.sprite.removeAllChildren()
            let spriteName = self.json["sprite"] as! String
            let trapSprite = Entity.loadSprite(type: self, spriteName: spriteName)
            self.sprite.addChild(trapSprite)
        }
    }
    
    func playSound(_ type: SoundType, on node: SKNode) {
        guard let sounds = self.soundInfo[type] else { return }
        
        let index = arc4random_uniform(UInt32(sounds.count))
        let sound = sounds[Int(index)]
                
        let play = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        node.run(play)
    }
}

