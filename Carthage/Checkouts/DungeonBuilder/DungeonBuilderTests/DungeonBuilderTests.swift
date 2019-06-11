//
//  DungeonBuilderTests.swift
//  DungeonBuilderTests
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import XCTest
@testable import DungeonBuilder

class DungeonBuilderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateDungeon() {
        let dungeonBuilder = DungeonBuilder(configuration: Configuration.Default)
        let dungeon = dungeonBuilder.build(name: "Cellar of Bloody Death")
        
        print(dungeon)
    }
    
    func testSetRoomId() {
        var node: Node = .perimeter
        
        node.setRoom(roomId: 5)
        assert(node.roomId == 5)
        node.setRoom(roomId: 3)
        assert(node.roomId == 3)
        assert(node.contains(.perimeter))
        
        node.insert([.blocked, .arch])
        node.setRoom(roomId: 105)
        assert(node.roomId == 105)
        assert(node.contains([.perimeter, .blocked, .arch]))
    }
}
