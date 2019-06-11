//
//  MainMenuScene.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 11/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Fenris
import CoreGraphics

#if os(macOS)
import Cocoa
#endif

class MainMenuScene : MenuScene {
    init(size: CGSize) {
        let options: [MenuOption] = [
            Button(title: "New Singleplayer Game", selected: {
                print("New Game")

                do {
                    let entityLoader = EntityLoader()
                    let tiles = try entityLoader.loadEntities()
                    let entityFactory = EntityFactory()
                    for tile in tiles {
                        entityFactory.register(entity: tile)
                    }
                    let game = Game(entityFactory: entityFactory)
                    ServiceLocator.shared.sceneManager.transitionTo(
                        scene: GameScene(game: game, size: size),
                        animation: .fade
                    )
                } catch let error {
                    print("error: \(error)")
                }
            }),
            Button(title: "Resume", selected: {
                print("resume")
            }),
            Button(title: "Settings", selected: {
                ServiceLocator.shared.sceneManager.transitionTo(
                    scene: SettingsScene(
                        size: size
                    ),
                    animation: .push
                )
            }),
            Button(title: "Quit", selected: {
                print("quit")
            })
        ]

        super.init(size: size, controlHeight: 30, options: options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
