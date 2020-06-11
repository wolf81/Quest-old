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
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        
        try! ServiceLocator.shared.add(service: SceneManager(view: skView))
        try! ServiceLocator.shared.get(service: SceneManager.self).fade(to: MainMenuScene.self)
    }
}
