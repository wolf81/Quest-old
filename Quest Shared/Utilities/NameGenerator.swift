//
//  NameGenerator.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 11/06/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

fileprivate typealias ChainInfo = [String: [String: UInt32]]

extension ChainInfo {
    private struct Key {
        static let partsCount = "partsCount"
        static let nameLength = "nameLength"
        static let initial = "initial"
        static let tableLength = "tableLength"
    }
    
    mutating func incrementCountFor(key: String, token: String) {
        if let _ = self[key] {
            if let value =  valueFor(key: key, token: token) {
                setValue(value + 1, forKey: key, token: token)
            } else {
                setValue(1, forKey: key, token: token)
            }
        } else {
            setValue(1, forKey: key, token: token)
        }
    }
    
    mutating func incrementPartsCountFor(token: String) {
        incrementCountFor(key: ChainInfo.Key.partsCount, token: token)
    }
    
    mutating func incrementNameLengthFor(token: String) {
        incrementCountFor(key: ChainInfo.Key.nameLength, token: token)
    }
    
    mutating func incrementInitialCountFor(token: String) {
        incrementCountFor(key: ChainInfo.Key.initial, token: token)
    }

    mutating func scaleChain() -> Self {
        var lengthInfo: [String: UInt32] = [:]
        
        for key in self.keys {
            lengthInfo[key] = 0
            
            for token in self[key]!.keys {
                let count = Double(valueFor(key: key, token: token) ?? 0)
                let weighted = UInt32(floor(pow(count, 1.3)))
                setValue(weighted, forKey: key, token: token)
                lengthInfo[key]! += weighted
            }
        }
        self[ChainInfo.Key.tableLength] = lengthInfo
        
        return self
    }
    
    func markovName() -> String {
        let partsCountString = selectLinkFor(key: ChainInfo.Key.partsCount)
        var names: [String] = []

        let partsCount = Int(partsCountString) ?? 0
        for _ in 0 ..< partsCount {
            let nameLengthString = selectLinkFor(key: ChainInfo.Key.nameLength)
            let nameLength = Int(nameLengthString) ?? 0
            
            var character = selectLinkFor(key: ChainInfo.Key.initial)
            var name = character
            var lastCharacter = character
            
            while name.count < nameLength {
                character = selectLinkFor(key: lastCharacter)
                name.append(character)
                lastCharacter = character
            }
            names.append(name.trimmingCharacters(in: CharacterSet.whitespaces))
        }
        
        return names.joined(separator: " ");
    }
    
    // MARK: - Private
        
    private func selectLinkFor(key: String) -> String {
        let length = self[ChainInfo.Key.tableLength]![key] ?? 0
        let idx = floor(Double(arc4random_uniform(length)))
        
        var value: UInt32 = 0
        for token in tokensFor(key: key) ?? [] {
            value += valueFor(key: key, token: token) ?? 0
            if UInt32(idx) < value { return token }
        }
        
        return " "
    }
    
    private func valueFor(key: String, token: String) -> UInt32? {
        if let tokenInfo = self[key] {
            return tokenInfo[token]
        }
        return nil
    }
    
    private mutating func setValue(_ value: UInt32, forKey key: String, token: String) {
        if self[key] == nil {
            self[key] = [:]
        }
        
        self[key]![token] = value
    }
    
    private func tokensFor(key: String) -> [String]? {
        if let tokenInfo = self[key] {
            return Array(tokenInfo.keys)
        }
        return nil
    }
}

public class NameGenerator {
    private let nameInfo: [String: [String]]
    
    private var chainInfo: [String: ChainInfo] = [:]
    
    public init(nameInfo: [String: [String]]) {
        self.nameInfo = nameInfo
    }
    
    public func generateNameFor(category: String) -> String {
        guard let chain = generateMarkovChainFor(category: category) else { return "" }

        return chain.markovName()
    }
    
    public func generateNamesFor(category: String, count: UInt32) -> [String] {
        var list: [String] = []
        
        for _ in (0 ..< count) {
            list.append(generateNameFor(category: category))
        }
        
        return list
    }
    
    // MARK: - Private
    
    private func generateMarkovChainFor(category: String) -> ChainInfo? {
        if let chain = self.chainInfo[category] {
            return chain
        } else {
            if let nameList = self.nameInfo[category] {
                let chain = constructChainFor(nameList: nameList)
                self.chainInfo[category] = chain
                return chain
            }
        }
                
        return nil
    }
    
    private func constructChainFor(nameList: [String]) -> ChainInfo {
        var chain = ChainInfo()
        
        for i in 0 ..< nameList.count {
            let names = nameList[i].split(separator: " ")
            chain.incrementPartsCountFor(token: "\(names.count)")
            
            for j in 0 ..< names.count {
                let name = String(names[j])
                chain.incrementNameLengthFor(token: "\(name.count)")
                
                let character = String(name.prefix(1))
                chain.incrementInitialCountFor(token: character)
                
                var string = name.suffix(name.count - 1)
                var lastCharacter = character
                
                while string.count > 0 {
                    let character = String(string.prefix(1))
                    chain.incrementCountFor(key: lastCharacter, token: character)
                    string = string.suffix(string.count - 1)
                    lastCharacter = character
                }
            }
        }
        
        return chain.scaleChain()
    }
}

public class NameInfo: JSONConstructable {
    let nameInfo: [String: [String]]
    
    required init(json: [String : Any]) {
        self.nameInfo = json as! [String: [String]]
    }
}
