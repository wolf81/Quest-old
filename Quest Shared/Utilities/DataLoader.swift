//
//  DataLoader.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 26/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class DataLoader {
    private init() {}
    
    static func load<T: JSONConstructable>(type: T.Type, fromFileNamed filename: String, inDirectory directory: String) throws -> T {
        let path = Bundle.main.path(forResource: filename, ofType: "json", inDirectory: directory)!
        print("load file: \(path)")
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return T(json: json as! [String: Any])
    }
    
    static func loadEntity<T: EntityProtocol>(type: T.Type, fromPath path: String, entityFactory: EntityFactory) throws -> T {
        print("load entity: \(path)")
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return T(json: json, entityFactory: entityFactory)
    }
}
