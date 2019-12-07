//
//  GameViewController.swift
//  Quest iOS
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Fenris

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let menuConfig = MenuConfiguration(menuWidth: 320, rowHeight: 40, titleFont: Font(name: "Papyrus", size: 22)!, labelFont: Font(name: "Papyrus", size: 18)!)
        let menu = SimpleMenuBuilder()
            .withRow(item: ButtonItem(title: "New Game", onClick: { print("show new game scene") }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Continue Game", onClick: { print("continue existing game") }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Settings", onClick: { print("Settings") }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Quit", onClick: { print("quit") }))
            .build()
        let menuScene = MenuScene(size: self.view.frame.size, configuration: menuConfig, menu: menu)
        
//        let scene = GameScene.newGameScene(size: CGSize(width: 1024, height: 768))

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(menuScene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
