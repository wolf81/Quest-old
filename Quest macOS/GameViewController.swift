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
    private var skView: SKView { return self.view as! SKView }

    fileprivate let serviceLocator = ServiceLocator.shared
        
    fileprivate var heroBuilder = HeroBuilder()
    
    private unowned var gameScene: GameScene?
            
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
    func gameDidMove(hero: Hero, to coord: SIMD2<Int32>, duration: TimeInterval) {
        self.gameScene?.moveCamera(to: coord, duration: duration)
    }
}

// MARK: - MainMenuSceneDelegate

extension GameViewController: MainMenuSceneDelegate {
    func mainMenuDidSelectNewGame() {
        let createCharacterScene = SceneBuilder.createCharacterMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(createCharacterScene, transition: SKTransition.push(with: .left, duration: 0.5))
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

// MARK: - ChooseAttributesMenuDelegate

extension GameViewController: ChooseAttributesMenuDelegate {
    func chooseAttributesMenuDidSelectBack() {
        let menuScene = SceneBuilder.createCharacterMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(menuScene, transition: SKTransition.push(with: .right, duration: 0.5))
    }
    
    func chooseAttributesMenuDidSelect(attributes: Attributes) {
        do {
            let entityFactory = EntityFactory()
            try EntityLoader.loadEntities(for: entityFactory)

            let armor = try! entityFactory.newEntity(name: "Studded Leather") as! Armor
            let weapon = try! entityFactory.newEntity(name: "Longsword") as! Weapon
            let shield = try! entityFactory.newEntity(name: "Buckler") as! Shield
            let equipment = Equipment(armor: armor, weapon: weapon, shield: shield)

            self.heroBuilder = self.heroBuilder
                .with(attributes: attributes)
                .with(name: "Kendrick")
                .with(equipment: equipment)
            
            let hero = try self.heroBuilder.build()
            let game = Game(entityFactory: entityFactory, delegate: self, hero: hero)
            let gameScene = GameScene(game: game, size: self.view.bounds.size)
            self.skView.presentScene(gameScene, transition: SKTransition.fade(withDuration: 0.5))
            
            self.gameScene = gameScene
        } catch let error {
            print("error: \(error)")
        }
    }
}

// MARK: - CreateCharacterMenuDelegate

extension GameViewController: CreateCharacterMenuDelegate {
    func createCharacterMenuDidSelect(race: Race, role: Role, gender: Gender) {
        self.heroBuilder = self.heroBuilder
            .with(race: race)
            .with(role: role)
            .with(gender: gender)
        
        let menuScene = SceneBuilder.chooseAttributesMenu(size: self.view.bounds.size, race: race, delegate: self)
        self.skView.presentScene(menuScene, transition: SKTransition.push(with: .left, duration: 0.5))
    }
    
    func createCharacterMenuDidSelectBack() {
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
