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
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        try! ServiceLocator.shared.add(service: SceneManager(view: skView))
        try! ServiceLocator.shared.get(service: SceneManager.self).fade(to: MainMenuScene.self)
    }
}

/*
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
        NSApp.terminate(self)
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

            let armor = try! entityFactory.newEntity(type: Armor.self, name: "Studded Leather")
            let meleeWeapon = try! entityFactory.newEntity(type: Weapon.self, name: "Longsword")
            let rangedWeapon = try! entityFactory.newEntity(type: Weapon.self, name: "Shortbow")
            let shield = try! entityFactory.newEntity(type: Shield.self, name: "Buckler") 
            let equipment = Equipment(armor: armor, meleeWeapon: meleeWeapon, rangedWeapon: rangedWeapon, shield: shield)

            self.heroBuilder = self.heroBuilder
                .with(attributes: attributes)
                .with(name: "Kendrick")
                .with(equipment: equipment)
            
            let hero = try self.heroBuilder.build()
            let game = Game(entityFactory: entityFactory, hero: hero)
            
            try! ServiceLocator.shared.get(service: SceneManager.self).fade(to: GameScene.self)
        } catch let error {
            print("error: \(error)")
        }
    }
}

// MARK: - SettingsMenuDelegate

extension GameViewController: SettingsMenuDelegate {
    func settingsMenuDidSelectBack() {
        let menuScene = SceneBuilder.mainMenu(size: self.view.bounds.size, delegate: self)
        self.skView.presentScene(menuScene, transition: SKTransition.push(with: .right, duration: 0.5))
    }
}

 */
