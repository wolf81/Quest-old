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
    case disabled // hide the trap
    
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
    
    private(set) var state: TrapState = .hidden {
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
        let bonus = hero.attributes.mind.bonus + hero.skills.subterfuge + hero.level / 2
        let roll = HitDie.d20(1, bonus).randomValue

        print("search trap: \(roll) vs \(self.searchDifficultyClass)")

        let trapFound = roll >= self.searchDifficultyClass
        if trapFound {
            self.state = .discovered
        }
        
        return trapFound
    }
    
    @discardableResult
    func disable(hero: Hero) -> Bool {
        let bonus = hero.attributes.dexterity.bonus + hero.skills.subterfuge
        let roll = HitDie.d20(1, bonus).randomValue
        
        print("disable trap: \(roll) vs \(self.disableDifficultyClass)")

        let disabled = roll >= self.disableDifficultyClass
        if disabled {
            self.state = .disabled
        } else {
            self.trigger(actor: hero)
        }
        
        return disabled
    }
    
    @discardableResult
    func trigger(actor: Actor) -> Int {
        self.state = .triggered
        
        let attackDie = HitDie.d20(1, 0)

        guard attackDie.randomValue >= self.attack else { return 0 }
        
        let damage = self.damageDie.randomValue
        actor.reduceHealth(with: damage)
                
        // TODO: this is unsafe, we add and remove search otherwise using the game state. Not sure
        // what is the best approach and this needs some consideration to do properly
        if let hero = actor as? Hero, damage > 0, hero.isSearching {
            hero.removeEffect(named: "Search")
        }
        
        return damage
    }
        
    func configure(withTile tile: TileProtocol) {
        self.sprite = tile.sprite.copy() as! SKSpriteNode
        self.state = .hidden
        self.coord = tile.coord
    }
    
    private func updateForTrapState() {
        switch self.state {
        case .disabled: self.sprite.removeAllChildren()
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

extension Trap: Targetable {
    var isTargetable: Bool { self.state == .discovered }
}

extension Trap: Interactable {
    var canInteract: Bool { self.state == .discovered }

    func interact(state: GameState) {
        if let hero = state.currentActor as? Hero {
            
        }
        
    }
}
