//
//  NameGenerator.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 11/06/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
    
fileprivate class MarkovChain {
    fileprivate typealias ChainInfo = [String: [String: UInt32]]

    private var chainInfo = ChainInfo()
    
    private struct Key {
        static let partsCount = "partsCount"
        static let nameLength = "nameLength"
        static let initial = "initial"
        static let tableLength = "tableLength"
    }
    
    func incrementCountFor(key: String, character: String) {
        if let _ = self.chainInfo[key] {
            if let value =  valueFor(key: key, token: character) {
                setValue(value + 1, forKey: key, token: character)
            } else {
                setValue(1, forKey: key, token: character)
            }
        } else {
            setValue(1, forKey: key, token: character)
        }
    }
    
    func incrementPartsCountFor(character: String) {
        incrementCountFor(key: Key.partsCount, character: character)
    }
    
    func incrementNameLengthFor(character: String) {
        incrementCountFor(key: Key.nameLength, character: character)
    }
    
    func incrementInitialCountFor(character: String) {
        incrementCountFor(key: Key.initial, character: character)
    }

    func scale() {
        var lengthInfo: [String: UInt32] = [:]
        
        for key in self.chainInfo.keys {
            lengthInfo[key] = 0
            
            for token in self.chainInfo[key]!.keys {
                let count = Double(valueFor(key: key, token: token) ?? 0)
                let weighted = UInt32(floor(pow(count, 1.3)))
                setValue(weighted, forKey: key, token: token)
                lengthInfo[key]! += weighted
            }
        }
        self.chainInfo[Key.tableLength] = lengthInfo
    }
    
    func markovName() -> String {
        let partsCountString = selectLinkFor(key: Key.partsCount)
        var names: [String] = []

        let partsCount = Int(partsCountString) ?? 0
        for _ in 0 ..< partsCount {
            let nameLengthString = selectLinkFor(key: Key.nameLength)
            let nameLength = Int(nameLengthString) ?? 0
            
            var character = selectLinkFor(key: Key.initial)
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
        let length = self.chainInfo[Key.tableLength]![key] ?? 0
        let idx = floor(Double(arc4random_uniform(length)))
        
        var value: UInt32 = 0
        for token in tokensFor(key: key) ?? [] {
            value += valueFor(key: key, token: token) ?? 0
            if UInt32(idx) < value { return token }
        }
        
        return " "
    }
    
    private func valueFor(key: String, token: String) -> UInt32? {
        if let tokenInfo = self.chainInfo[key] {
            return tokenInfo[token]
        }
        return nil
    }
    
    private func setValue(_ value: UInt32, forKey key: String, token: String) {
        if self.chainInfo[key] == nil {
            self.chainInfo[key] = [:]
        }
        
        self.chainInfo[key]![token] = value
    }
    
    private func tokensFor(key: String) -> [String]? {
        if let tokenInfo = self.chainInfo[key] {
            return Array(tokenInfo.keys)
        }
        return nil
    }
}

public class NameGenerator {
    private let nameInfo: [String: [String]]
    
    private var chainInfo: [String: MarkovChain] = [:]
    
    private let invalidPatterns: [String]
    
    convenience init(nameInfo: [String: [String]]) {
        self.init(nameInfo: nameInfo, invalidPatterns: [])
    }
    
    public init(nameInfo: [String: [String]], invalidPatterns: [String]) {
        self.invalidPatterns = invalidPatterns
        self.nameInfo = nameInfo
    }
    
    public func generateName() -> String {
        guard let chain = generateMarkovChainFor(category: "names") else { return "" }
        
        let name = chain.markovName()
        
        if isValid(name: name) == false {
            return generateName()
        }        
        
        return name
    }
    
    public func generateNames(count: UInt32) -> [String] {
        var list: [String] = []
        
        for _ in (0 ..< count) {
            list.append(generateName())
        }
        
        return list
    }
    
    // MARK: - Private
    
    private func isValid(name: String) -> Bool {
        for pattern in self.invalidPatterns {
            let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: name.count)
            let match = regex.firstMatch(in: name, options: [], range: range)
            if match != nil { return false }
        }
        
        return true
    }
    
    private func generateMarkovChainFor(category: String) -> MarkovChain? {
        if let chain = self.chainInfo[category] {
            return chain
        } else {
            if let nameList = self.nameInfo[category] {
                let chain = constructMarkovChainFor(nameList: nameList)
                self.chainInfo[category] = chain
                return chain
            }
        }
                
        return nil
    }
    
    private func constructMarkovChainFor(nameList: [String]) -> MarkovChain {
        let chain = MarkovChain()
        
        for i in 0 ..< nameList.count {
            let names = nameList[i].split(separator: " ")
            chain.incrementPartsCountFor(character: "\(names.count)")
            
            for j in 0 ..< names.count {
                let name = String(names[j])
                chain.incrementNameLengthFor(character: "\(name.count)")
                
                let character = String(name.prefix(1))
                chain.incrementInitialCountFor(character: character)
                
                var string = name.suffix(name.count - 1)
                var lastCharacter = character
                
                while string.count > 0 {
                    let character = String(string.prefix(1))
                    chain.incrementCountFor(key: lastCharacter, character: character)
                    string = string.suffix(string.count - 1)
                    lastCharacter = character
                }
            }
        }
        
        chain.scale()
        
        return chain
    }
}

public class NameInfo: JSONConstructable {
    let nameInfo: [String: [String]]
    
    let filters: [String]
    
    required init(json: [String : Any]) {
        self.nameInfo = json as! [String: [String]]
        
        self.filters = json["filters"] as? [String] ?? []
    }
}
