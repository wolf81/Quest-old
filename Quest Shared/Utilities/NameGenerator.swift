//
//  NameGenerator.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 11/06/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

fileprivate typealias ChainInfo = [String: [String: UInt32]]

public class NameGenerator {
    private let nameInfo: [String: [String]]
    
    private var chainInfo: [String: [String: [String: UInt32]]] = [:]
    
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
            chain = incrementChain(&chain, key: "parts", token: "\(names.count)")
            
            for j in 0 ..< names.count {
                let name = String(names[j])
                
                chain = incrementChain(&chain, key: "name_len", token: "\(name.count)")
                
                let c = String(name.prefix(1))
                chain = incrementChain(&chain, key: "initial", token: c)
                
                var string = name.suffix(name.count - 1)
                var last_c = c
                
                while string.count > 0 {
                    let c = String(string.prefix(1))
                    chain  = incrementChain(&chain, key: last_c, token: c)
                    string = string.suffix(string.count - 1)
                    last_c = c
                }
            }
        }
        
        return scaleChain(&chain)
    }
    
    private func incrementChain(_ chain: inout ChainInfo, key: String, token: String) -> ChainInfo {
        if let _ = chain[key] {
            if let _ = chain[key]?[token] {
                chain[key]![token]! += 1
            } else {
                chain[key]![token] = 1
            }
        } else {
            chain[key] = [:]
            chain[key]![token] = 1
        }
        
        return chain
    }
    
    private func scaleChain(_ chain: inout ChainInfo) -> ChainInfo {
        var tableLen: [String: UInt32] = [:]
        
        for key in chain.keys {
            tableLen[key] = 0
            
            for token in chain[key]!.keys {
                let count = Double(chain[key]![token]!)
                let weighted = pow(count, 1.3)
                let n = floor(weighted)
                chain[key]![token]! = UInt32(n)
                tableLen[key]! += UInt32(n)
            }
        }
        chain["table_len"] = tableLen
        
        return chain
    }
    
    private func markovNameFromChain(_ chain: ChainInfo) -> String {
        let numberFormatter = NumberFormatter()
        
        let parts = selectLinkFromChain(chain, key: "parts")
        var names: [String] = []
        
        let x = numberFormatter.number(from: parts)?.intValue ?? 0
        // TODO: double check this code ... in JS seems different
        for _ in 0 ..< x
        {
            let nameLen = selectLinkFromChain(chain, key: "name_len")
            let m = numberFormatter.number(from: nameLen)?.intValue ?? 0
            
            var c = selectLinkFromChain(chain, key: "initial")
            var name = c
            var last_c = c
            
            while name.count < m {
                c = selectLinkFromChain(chain, key: last_c)
                name.append(c)
                last_c = c
            }
            names.append(name)
        }
        
        return names.joined(separator: " ");
    }
    
    private func selectLinkFromChain(_ chain: ChainInfo, key: String) -> String {
        let len = chain["table_len"]![key] ?? 0
        let idx = floor(Double(arc4random_uniform(len)))
        
        var t: UInt32 = 0
        for token in chain[key]?.keys ?? [:].keys  {
            t += chain[key]![token]!
            if UInt32(idx) < t { return token }
        }
        return "-"
    }
}

class NameInfo: JSONConstructable {
    let nameInfo: [String: [String]]
    
    required init(json: [String : Any]) {
        self.nameInfo = json as! [String: [String]]
    }
}
