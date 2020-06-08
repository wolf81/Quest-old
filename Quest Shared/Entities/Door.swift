//
//  Door.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

enum DoorState {
    case opened
    case closed
}

class Door: GKGridGraphNode & TileProtocol {
    var didExplore: Bool = false

    private(set) var json: [String: Any] = [:]
        
    lazy var name: String = { self.json["name"] as! String }()
    
    var sprite: SKSpriteNode = SKSpriteNode(color: .clear, size: Constants.tileSize)

    var coord: vector_int2 { return self.gridPosition }

    var state: DoorState = .closed {
        didSet {
            updateForDoorState()
        }
    }
            
    private lazy var soundInfo: [SoundType: [String]] = {
        guard let soundInfo = self.json["sounds"] as? [String: [String]] else { return [:] }
            
        var result: [SoundType: [String]] = [:]
        for (typeName, soundNames) in soundInfo {
            let soundType = SoundType(rawValue: typeName)!
            result[soundType] = soundNames
        }

        return result
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        self.json = json
        
        super.init(gridPosition: coord)
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.json = json

        super.init(gridPosition: vector2(0, 0))
    }
         
    func configure(withTile tile: TileProtocol) {
        self.sprite = tile.sprite.copy() as! SKSpriteNode        
        updateForDoorState()
    }
        
    func updateForDoorState() {
        let spriteInfo = self.json["sprite"] as! [String: String]
        var sprite: SKSpriteNode
        
        switch self.state {
        case .opened: sprite = Entity.loadSprite(type: self, spriteName: spriteInfo["open"]!)
        case .closed: sprite = Entity.loadSprite(type: self, spriteName: spriteInfo["closed"]!)
        }
                
//        self.sprite.run(SKAction.sequence([
//            SKAction.fadeIn(withDuration: 1.0),
//            SKAction.run({ door.sprite = newSprite })
//        ]))

        self.sprite.removeAllChildren()
        self.sprite.addChild(sprite)
    }
        
    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        copyInternal(coord: coord, entityFactory: entityFactory)
    }

    func playSound(_ type: SoundType, on node: SKNode) {
        guard let sounds = self.soundInfo[type] else { return }
        
        let index = arc4random_uniform(UInt32(sounds.count))
        let sound = sounds[Int(index)]
                
        let play = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        node.run(play)                
    }

    private func copyInternal<T: Door>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        return T(json: self.json, entityFactory: entityFactory, coord: coord)
    }
}

extension Door: Targetable {
    var isTargetable: Bool { true }
}

extension Door: Interactable {
    var canInteract: Bool { true }

    func interact(state: GameState) {
        self.state = ((self.state == .opened) ? .closed : .opened)
        
        state.currentActor.updateVisibility()
    }
}
