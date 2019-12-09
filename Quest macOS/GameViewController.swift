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

class GameViewController: NSViewController {
    let serviceLocator = ServiceLocator.shared
    
    var skView: SKView { return self.view as! SKView }
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let menuScene = SceneBuilder.mainMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.5))
    }
}

// MARK: - GameDelegate

extension GameViewController: GameDelegate {
    func gameDidMove(player: Hero, toCoord: SIMD2<Int32>, duration: TimeInterval) {
        self.gameScene?.moveCamera(toPosition: pointForCoord(toCoord), duration: duration)
    }
}

// MARK: - MainMenuSceneDelegate

extension GameViewController: MainMenuSceneDelegate {
    func mainMenuDidSelectNewGame() {
        let chooseRaceScene = SceneBuilder.chooseRaceMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(chooseRaceScene, transition: SKTransition.push(with: .left, duration: 0.5))
    }
    
    func mainMenuDidSelectContinueGame() {
    }
    
    func mainMenuDidSelectSettings() {
        let settingsScene = SceneBuilder.settingsMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(settingsScene, transition: SKTransition.push(with: .left, duration: 0.5))
    }
    
    func mainMenuDidSelectQuit() {
    }
}

// MARK: - ChooseRaceMenuDelegate

extension GameViewController: ChooseRaceMenuDelegate {
    func chooseRaceMenuDidSelectRace(race: String) {
        print("selected race: \(race)")
        
        do {
            let entityFactory = EntityFactory()
            try EntityLoader.loadEntities(for: entityFactory)
            let game = Game(entityFactory: entityFactory, delegate: self)
            let gameScene = GameScene(game: game, size: self.view.bounds.size)
            self.skView.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
            
            self.gameScene = gameScene
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func chooseRaceMenuDidSelectBack() {
        let menuScene = SceneBuilder.mainMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(menuScene, transition: SKTransition.push(with: .right, duration: 0.5))
    }
}

// MARK: - SettingsMenuDelegate

extension GameViewController: SettingsMenuDelegate {
    func settingsMenuDidSelectBack() {
        let menuScene = SceneBuilder.mainMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(menuScene, transition: SKTransition.push(with: .right, duration: 0.5))
    }
}
