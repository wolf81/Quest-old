//
//  Monster.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import Fenris

enum DieRoll {
    case random
    case maximum
}

class Actor: Entity {
    var hitPoints: HitPoints

    var isAlive: Bool { return self.hitPoints.current > 0 }

    var isResting: Bool { self.effects.contains(where: { $0.name == "Sleep" })}

    private(set) var skills: Skills
        
    private(set) var attributes: Attributes = Attributes(strength: 12, dexterity: 12, mind: 12)
    
    private(set) var meleeAttackBonus: Int = 0

    private(set) var rangedAttackBonus: Int = 0

    private(set) var armorClass: Int = 0
        
    private(set) var sight: Int32 = 5 {
        didSet {
            updateVisibility()
        }
    }
    
    private(set) var level: Int = 1
    
    private(set) var energy = Energy()
            
    private(set) var healthBar: HealthBar!
    
    private(set) var unarmed: Weapon
    
    private(set) var energyCost: EnergyCost
                    
    private let inventory: Inventory = Inventory()
    
    private var action: Action?        
        
    override var coord: vector_int2 {
        didSet {
            updateVisibility()
        }
    }
    
    var isRangedWeaponEquipped: Bool { self.equippedWeapon.range > 1 }
    
    var visibleCoords = Set<vector_int2>()

    var visibility: RaycastVisibility?
        
    var canTakeTurn: Bool { self.energy.amount > 0 }
    
    var isAwaitingInput: Bool { self.action == nil }
    
    private lazy var soundInfo: [SoundType: [String]] = {
        guard let soundInfo = self.json["sounds"] as? [String: [String]] else { return [:] }
            
        var result: [SoundType: [String]] = [:]
        for (typeName, soundNames) in soundInfo {
            let soundType = SoundType(rawValue: typeName)!
            result[soundType] = soundNames
        }

        return result
    }()
        
    final func setAction(_ action: Action) {
        self.action = action
    }
    
    final func getAction() -> Action? {
        defer {
            self.action = nil
        }

        return self.action
    }
    
    func update(state: GameState, deltaTime: TimeInterval) { fatalError() }
    
    var effects: [Effect] { self.equipmentEffects + self.otherEffects }
    
    private var otherEffects: [Effect] = []
    
    private var equipmentEffects: [Effect] {
        let equippedItems: [Equippable] = [self.equippedArmor, self.equippedShield, self.equippedRing, self.equippedWeapon, self.equippedBoots, self.equippedHeadpiece]
        return equippedItems.compactMap({ $0.effects }).flatMap({ $0 })
    }

    init(json: [String : Any], hitPoints: Int, armorClass: Int, skills: Skills, equipment: [Equippable], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.armorClass = armorClass
        self.skills = skills
        self.unarmed = try! entityFactory.newEntity(type: Weapon.self, name: "Unarmed")
        self.energyCost = EnergyCost(json: json["energyCost"] as? [String: Int] ?? [:])
        self.sight = json["sight"] as? Int32 ?? 5
        
        super.init(json: json, entityFactory: entityFactory)
                                
        self.hitPoints.delegate = self
        
        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
        
        equipment.forEach({ self.inventory.equip($0) })
        updateSpriteForEquipment()
    }
    
    init(name: String, hitPoints: Int, race: Race, gender: Gender, attributes: Attributes, skills: Skills, equipment: [Equippable], backpack: [Lootable], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: hitPoints)
        self.skills = skills
        self.attributes = attributes
        self.unarmed = try! entityFactory.newEntity(type: Weapon.self, name: "Unarmed")
        self.energyCost = EnergyCost()

        super.init(json: ["name": name, "sprite": "\(race)_\(gender)"], entityFactory: entityFactory)
        
        self.hitPoints.delegate = self
        
        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
        
        self.inventory.append(backpack)
        
        equipment.forEach({ self.inventory.equip($0 )})
        updateSpriteForEquipment()
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.hitPoints = HitPoints(base: 1)
        self.skills = Skills(physical: 0, subterfuge: 0, knowledge: 0, communication: 0)
        self.unarmed = try! entityFactory.newEntity(type: Weapon.self, name: "Unarmed")
        self.energyCost = EnergyCost(json: json["energyCost"] as? [String: Int] ?? [:])

        super.init(json: json, entityFactory: entityFactory)

        self.hitPoints.delegate = self
        
        self.healthBar = Actor.addHealthBar(sprite: self.sprite)
    }
    
    func getMeleeAttackDamage(_ dieRoll: DieRoll) -> Int {
        dieRoll == .maximum ? self.equippedWeapon.damage.maxValue : self.equippedWeapon.damage.randomValue
    }

    func getRangedAttackDamage(_ dieRoll: DieRoll) -> Int {
        dieRoll == .maximum ? self.equippedWeapon.damage.maxValue : self.equippedWeapon.damage.randomValue
    }
    
    func getAction(state: Game) -> Action? {
        return nil
    }
        
    func updateSpriteForEquipment() {
        let children = self.sprite.children.filter({ $0 != self.healthBar })
        for child in children {
            child.removeFromParent()
        }
        
        let excludedSlots: [EquipmentSlot] = [.ring, .mainhand2, .offhand2]
        for (slot, equipment) in self.inventory.equippedItems {
            guard excludedSlots.contains(slot) == false else { continue }
            
            self.sprite.addChild(equipment.equipSprite)
        }
    }
    
    func reduceHealth(with hitPoints: Int) {
        var hitPointsToTake = hitPoints
        
        for effect in self.effects {
            if effect.type == .reduceDamage {
                hitPointsToTake -= effect.value
            }
        }
        
        self.hitPoints.remove(max(hitPointsToTake, 0))
    }
    
    func toggleWeapons() {
        self.inventory.toggleEquippedWeapons()
        updateSpriteForEquipment()
        
        NotificationCenter.default.post(name: Notification.Name.actorDidChangeEquipment, object: nil)
    }
    
    func playSound(_ type: SoundType, on node: SKNode) {
        guard let sounds = self.soundInfo[type] else { return }
        
        let index = arc4random_uniform(UInt32(sounds.count))
        let sound = sounds[Int(index)]
                
        let play = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        node.run(play)
    }
    
    func updateVisibility() {
        // TODO: only call update when coords changed since last call
        self.visibleCoords.removeAll()
        self.visibility?.compute(origin: self.coord, rangeLimit: self.sight)
    }
    
    func showBlood(duration: TimeInterval) {
        // TODO: need a cleaner way to handle blood, perhaps make it an effect?
        let imageNames = [
            "blood_red_0",
            "blood_red_5",
            "blood_red_6",
            "blood_red_7",
            "blood_red_8",
            "blood_red_9",
            "blood_red_10",
            "blood_red_11",
            "blood_red_12",
            "blood_red_13",
        ]
        let imageIdx = arc4random_uniform(UInt32(imageNames.count))
        let imageName = imageNames[Int(imageIdx)]
        let blood = SKSpriteNode(imageNamed: imageName)
        blood.alpha = 0.0
        blood.zPosition = 600_000
        self.sprite.addChild(blood)
        
        blood.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: duration / 6 * 1),
            SKAction.wait(forDuration: duration / 6 * 2),
            SKAction.fadeOut(withDuration: duration / 6 * 3),
            SKAction.run({ blood.removeFromParent() })
        ]))
    }
    
    public func applyEffect(effect: Effect) {
        self.otherEffects.append(effect)
        
        if effect.type == .limitSight {
            self.sight = Int32(effect.value)
        }
    }
    
    public func removeEffect(named name: String) {
        if self.otherEffects.contains(where: { $0.type == .limitSight }) {
            self.sight = self.json["sight"] as? Int32 ?? 5
        }
        
        self.otherEffects.removeAll(where: { $0.name == name })
    }
    
    // MARK: - Private
    
    private static func addHealthBar(sprite: SKSpriteNode) -> HealthBar {
        let barWidth = sprite.frame.width - 6
        let healthBar = HealthBar(size: CGSize(width: barWidth, height: 6))
        healthBar.position = CGPoint(x: -(barWidth / 2), y: (sprite.frame.height / 2) + 4)
        sprite.addChild(healthBar)
        return healthBar
    }
}

extension Actor: HitPointsDelegate {
    func hitPointsChanged(current: Int, total: Int) {
        let percentageHealth = CGFloat(current) / CGFloat(total)
        self.healthBar.update(health: percentageHealth)
    }
}

// MARK: - Backpack handling

extension Actor {
    var backpackItemCount: Int { self.inventory.backpack.count }
    
    func backpackItem(at index: Int) -> Lootable { self.inventory.backpack[index] }

    @discardableResult
    func addToBackpack(_ loot: Lootable) -> Int { self.inventory.append(loot) }
    
    @discardableResult
    func addToBackpack(_ loot: [Lootable]) -> Int { self.inventory.append(loot) }
        
    @discardableResult
    func removeFromBackpack(at index: Int) -> Lootable { self.inventory.remove(at: index) }
    
    @objc
    func useBackpackItem(at index: Int) {
        if let weapon = self.backpackItem(at: index) as? Weapon, weapon.style == .twoHanded {
            self.inventory.unequip(.offhand)
        }
        
        if let armor = self.backpackItem(at: index) as? Armor, armor.equipmentSlot == .offhand, self.equippedWeapon.style == .twoHanded {
            self.inventory.unequip(.mainhand)
        }

        self.inventory.use(at: index, with: self)        
    }
}

// MARK: - Equipment handling

extension Actor {
    var equippedWeapon: Weapon { self.inventory.equippedItems[.mainhand] as? Weapon ?? self.unarmed }
    
    var equippedArmor: Armor { self.inventory.equippedItems[.chest] as? Armor ?? Armor.none }
    
    var equippedShield: Armor { self.inventory.equippedItems[.offhand] as? Armor ?? Armor.none }
        
    var equippedRing: Accessory { self.inventory.equippedItem(in: .ring) as? Accessory ?? Accessory.none(type: .ring) }
    
    var equippedBoots: Accessory { self.inventory.equippedItem(in: .feet) as? Accessory ?? Accessory.none(type: .boots) }
    
    var equippedHeadpiece: Accessory { self.inventory.equippedItem(in: .head) as? Accessory ?? Accessory.none(type: .headpiece) }

    func equippedItem(in equipmentSlot: EquipmentSlot) -> Equippable? { self.inventory.equippedItem(in: equipmentSlot) }
    
    @discardableResult
    func unequip(_ equipmentSlot: EquipmentSlot) -> Bool { self.inventory.unequip(equipmentSlot) }
}
