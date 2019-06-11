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
        ServiceLocator.shared.provide(sceneManager: sceneManager)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        do {
            let scene = MainMenuScene(size: self.view.bounds.size)
            ServiceLocator.shared.sceneManager.transitionTo(scene: scene, animation: .fade)
        } catch let error {
            print("error: \(error)")
        }
    }
}
