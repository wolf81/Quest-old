//
//  Armor.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import CoreGraphics

class Armor: Entity & Equippable {
    enum ArmorType: String {
        case none
        case light
        case medium
        case heavy
        case shield
        
        init(rawValue: String) {
            switch rawValue {
            case "none": self = .none
            case "light": self = .light
            case "medium": self = .medium
            case "heavy": self = .heavy
            case "shield": self = .shield
            default: fatalError()
            }
        }
    }
            
    let armorClass: Int
    
    var equipmentSlot: EquipmentSlot { type == .shield ? .offhand : .chest }
    
    let type: ArmorType
    
    var effects: [Effect] = []
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        let armorClass = json["AC"] as! Int
        self.armorClass = armorClass
        
        let armorType = json["type"] as? String ?? "none"
        self.type = ArmorType(rawValue: armorType)
        
        super.init(json: json, entityFactory: entityFactory)
        
        configureSprite()
    }
    
    static var none: Armor {
        get {
            return self.init(json: ["AC": 0], entityFactory: EntityFactory())
        }
    }
    
    private func configureSprite() {
        guard let spriteInfo = self.json["sprite"] else { return }
        
        switch spriteInfo {
        case let spriteName as String:
            let texture = SKTexture(imageNamed: spriteName)
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: 48, height: 48))
            
            sprite.zPosition = DrawLayerHelper.zPosition(for: self)

            self.sprite = sprite
        case let spriteNames as [String]:
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            let context = CGContext(data: nil, width: 48, height: 48, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
            
            for spriteName in spriteNames {
                let image = Image(named: spriteName)!
                let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
                context!.draw(cgImage!, in: CGRect(x: 0, y: 0, width: 48, height: 48))
            }

            let result = context!.makeImage()!
            let texture = SKTexture(cgImage: result)
            
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: 48, height: 48))
            sprite.zPosition = DrawLayerHelper.zPosition(for: self)

            self.sprite = sprite
        default: fatalError()
        }
    }
}
