//
//  DataLoader.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 26/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import DungeonBuilder

class DataLoader {
    private init() {}
    
    static func load<T: JSONConstructable>(type: T.Type, fromFileNamed filename: String, inDirectory directory: String) throws -> T {
        let path = Bundle.main.path(forResource: filename, ofType: "json", inDirectory: directory)!
        let json = try loadJson(path: path)
        return T(json: json)
    }
    
    static func loadEntity<T: EntityProtocol>(type: T.Type, fromPath path: String, entityFactory: EntityFactory) throws -> T {
        let json = try loadJson(path: path)
        return T(json: json, entityFactory: entityFactory)
    }
    
    static func loadLevel(index: Int) throws -> [String: Any] {
        let path = Bundle.main.path(forResource: "\(index)", ofType: "json", inDirectory: "Data/Level")!
        return try loadJson(path: path)
    }
    
    private static func loadJson(path: String) throws -> [String: Any] {
        print("load file: \(path)")
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }
}
