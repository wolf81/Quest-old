//
//  GameViewController.swift
//  Quest macOS
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        do {
            let entityLoader = EntityLoader()
            let tiles = try entityLoader.loadEntities()
            
            let entityFactory = EntityFactory()
            for tile in tiles {
                entityFactory.register(entity: tile)
            }
            
            let game = Game(entityFactory: entityFactory)
            let scene = GameScene.newGameScene(game: game, size: self.view.bounds.size)
            skView.presentScene(scene)
        } catch let error {
            print("error: \(error)")
        }
    }
}

