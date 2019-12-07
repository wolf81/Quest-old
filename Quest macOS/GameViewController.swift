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
import Fenris

class GameViewController: NSViewController, ScenePresentable {
    let serviceLocator = ServiceLocator()
    
    unowned var gameScene: GameScene?
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }
    
    private func commonInit() {
        let sceneManager = SceneManager(viewController: self)
        serviceLocator.provide(sceneManager: sceneManager)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let menuScene = SceneBuilder.mainMenu(size: self.view.bounds.size, delegate: self)
        self.serviceLocator.sceneManager.transitionTo(scene: menuScene, animation: .fade)
    }
}

extension GameViewController: MainMenuSceneDelegate {
    func mainMenuDidSelectNewGame() {
        do {
            let entityLoader = EntityLoader()
            let tiles = try entityLoader.loadEntities()
            let entityFactory = EntityFactory()
            for tile in tiles {
                entityFactory.register(entity: tile)
            }
            let game = Game(entityFactory: entityFactory, delegate: self)
            let gameScene = GameScene(game: game, size: self.view.bounds.size)
            self.serviceLocator.sceneManager.transitionTo(scene: gameScene, animation: .fade)
            
            self.gameScene = gameScene
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func mainMenuDidSelectContinueGame() {
        
    }
    
    func mainMenuDidSelectSettings() {
        let settingsScene = SceneBuilder.settingsMenu(size: self.view.bounds.size, delegate: self)
        self.serviceLocator.sceneManager.transitionTo(scene: settingsScene, animation: .push)
    }
    
    func mainMenuDidSelectQuit() {
        
    }
}

extension GameViewController: SettingsMenuDelegate {
    func settingsMenuDidSelectBack() {
        let menuScene = SceneBuilder.mainMenu(size: self.view.bounds.size, delegate: self)
        self.serviceLocator.sceneManager.transitionTo(scene: menuScene, animation: .pop)
    }
}

extension GameViewController: GameDelegate {
    func gameDidMove(player: Hero, toCoord: SIMD2<Int32>, duration: TimeInterval) {
        self.gameScene?.moveCamera(toPosition: pointForCoord(toCoord), duration: duration)
    }
}
