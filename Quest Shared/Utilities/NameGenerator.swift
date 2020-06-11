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
    func valueFor(key: String, token: String) -> UInt32? {
        if let tokenInfo = self[key] {
            return tokenInfo[token]
        }
        return nil
    }
    
    mutating func setValue(_ value: UInt32, forKey key: String, token: String) {
        if self[key] == nil {
            self[key] = [:]
        }
        
        self[key]![token] = value
    }
    
    func tokensFor(key: String) -> [String]? {
        if let tokenInfo = self[key] {
            return Array(tokenInfo.keys)
        }
        return nil
    }
}

public class NameGenerator {
    private struct ChainInfoKey {
        static let partsCount = "partsCount"
        static let nameLength = "nameLength"
        static let initial = "initial"
        static let tableLength = "tableLength"
    }
    
    private let numberFormatter = NumberFormatter()
    
    private let nameInfo: [String: [String]]
    
    private var chainInfo: [String: ChainInfo] = [:]
    
    init(nameInfo: [String: [String]]) {
        self.nameInfo = nameInfo
    }
    
    public func generateNameFor(category: String) -> String {
        guard let chain = markovChain(category: category) else { return "" }

        return markovNameFromChain(chain)
    }
    
    public func generateNamesFor(category: String, count: UInt32) -> [String] {
        var list: [String] = []
        
        for _ in (0 ..< count) {
            list.append(generateNameFor(category: category))
        }
        
        return list
    }
    
    // MARK: - Private
    
    private func markovChain(category: String) -> ChainInfo? {
        if let chain = self.chainInfo[category] {
            return chain
        } else {
            if let nameList = self.nameInfo[category] {
                let chain = constructChain(nameList: nameList)
                self.chainInfo[category] = chain
                return chain
            }
        }
                
        return nil
    }
    
    private func constructChain(nameList: [String]) -> ChainInfo {
        var chain = ChainInfo()
        
        for i in 0 ..< nameList.count {
            let names = nameList[i].split(separator: " ")
            chain = incrementChain(&chain, key: ChainInfoKey.partsCount, token: "\(names.count)")
            
            for j in 0 ..< names.count {
                let name = String(names[j])
                chain = incrementChain(&chain, key: ChainInfoKey.nameLength, token: "\(name.count)")
                
                let character = String(name.prefix(1))
                chain = incrementChain(&chain, key: ChainInfoKey.initial, token: character)
                
                var string = name.suffix(name.count - 1)
                var lastCharacter = character
                
                while string.count > 0 {
                    let character = String(string.prefix(1))
                    chain  = incrementChain(&chain, key: lastCharacter, token: character)
                    string = string.suffix(string.count - 1)
                    lastCharacter = character
                }
            }
        }
        
        return scaleChain(&chain)
    }
    
    private func incrementChain(_ chain: inout ChainInfo, key: String, token: String) -> ChainInfo {
        if let _ = chain[key] {
            if let value =  chain.valueFor(key: key, token: token) {
                chain.setValue(value + 1, forKey: key, token: token)
            } else {
                chain.setValue(1, forKey: key, token: token)
            }
        } else {
            chain.setValue(1, forKey: key, token: token)
        }
        
        return chain
    }
    
    private func scaleChain(_ chain: inout ChainInfo) -> ChainInfo {
        var lengthInfo: [String: UInt32] = [:]
        
        for key in chain.keys {
            lengthInfo[key] = 0
            
            for token in chain[key]!.keys {
                let count = Double(chain.valueFor(key: key, token: token) ?? 0)
                let weighted = UInt32(floor(pow(count, 1.3)))
                chain.setValue(weighted, forKey: key, token: token)
                lengthInfo[key]! += weighted
            }
        }
        chain[ChainInfoKey.tableLength] = lengthInfo
        
        return chain
    }
    
    private func markovNameFromChain(_ chain: ChainInfo) -> String {
        let partsCountString = selectLinkFromChain(chain, forKey: ChainInfoKey.partsCount)
        var names: [String] = []

        let partsCount = self.numberFormatter.number(from: partsCountString)?.intValue ?? 0
        for _ in 0 ..< partsCount {
            let nameLengthString = selectLinkFromChain(chain, forKey: ChainInfoKey.nameLength)
            let nameLength = self.numberFormatter.number(from: nameLengthString)?.intValue ?? 0
            
            var character = selectLinkFromChain(chain, forKey: ChainInfoKey.initial)
            var name = character
            var lastCharacter = character
            
            while name.count < nameLength {
                character = selectLinkFromChain(chain, forKey: lastCharacter)
                name.append(character)
                lastCharacter = character
            }
            names.append(name.trimmingCharacters(in: CharacterSet.whitespaces))
        }
        
        return names.joined(separator: " ");
    }
    
    private func selectLinkFromChain(_ chain: ChainInfo, forKey key: String) -> String {
        let length = chain[ChainInfoKey.tableLength]![key] ?? 0
        let idx = floor(Double(arc4random_uniform(length)))
        
        var value: UInt32 = 0
        for token in chain.tokensFor(key: key) ?? [] {
            value += chain.valueFor(key: key, token: token) ?? 0
            if UInt32(idx) < value { return token }
        }
        return " "
    }
}

public class NameInfo: JSONConstructable {
    let nameInfo: [String: [String]]
    
    required init(json: [String : Any]) {
        self.nameInfo = json as! [String: [String]]
    }
}
