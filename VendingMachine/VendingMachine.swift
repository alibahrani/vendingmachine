//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Ali Al-Bahrani on 2016-09-02.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import UIKit


//Protocols 


protocol VendingMachineType {
    var selection: [VendingSelection] {get}
    var inventory: [VendingSelection: ItemType] {get set}
    var amountDeposited: Double {get set}
    
    init(inventory: [VendingSelection: ItemType])
    func vend(selection: VendingSelection, quantity: Double) throws
    func depost(amount: Double)
    func itemForCurrentSelection(selection: VendingSelection) ->ItemType?
}


protocol ItemType {
    var price: Double {get}
    var quantity: Double {get set}
    
}

//Error Type
enum InventoryError: ErrorType {
    case invalidResourceError
    case conversionError
    case invalidKey
}
enum VendingMachineError: ErrorType {
    case invalidSelection
    case outOfStock
    case insufisontFunds(requried: Double)
    
}

//Helper Classes 

class PlistConverter {
    class func dictionaryFromFile(resource: String, ofType type: String) throws -> [String: AnyObject]{
        guard let path = NSBundle.mainBundle().pathForResource(resource, ofType: type) else {
            throw InventoryError.invalidResourceError
        }
        guard let dictionary = NSDictionary(contentsOfFile: path), let castDictionary = dictionary as? [String: AnyObject]  else {
            throw InventoryError.conversionError
        }
        
        return castDictionary
        
        
    }
}

class InventoryUnarchiver {
    class func vendingInventoryFromDictionary(Dictionary: [String: AnyObject]) throws -> [VendingSelection : ItemType] {
        var inventory: [VendingSelection : ItemType] = [:]
        for (key, value) in Dictionary {
            if let itemDict = value as? [String : Double], let price = itemDict["price"], let quantity = itemDict["quantity"] {
                let item = VendingItem(price: price, quantity: quantity)
                guard let key = VendingSelection(rawValue: key) else {
                    throw InventoryError.invalidKey
            }
                inventory.updateValue(item, forKey: key)
        }
    }
        return inventory
}
    
}

//Concerete Type

enum VendingSelection: String {
    case Gum
    case SportsDrink
    case FruitJuice
    case Water
    case PopTart
    case CandyBar
    case Wrap
    case Sandwich
    case Cookie
    case Chips
    case DietSoda
    case Soda
    
    func icon() -> UIImage {
        if let image = UIImage(named: self.rawValue){
            return image
        }else {
            return UIImage(named: "Default")!
        }
        
    }
    
}

struct VendingItem: ItemType {
    let price: Double
    var quantity: Double
    
}

class VendingMachine: VendingMachineType {
        let selection: [VendingSelection] = [.Soda, .DietSoda, .Chips, .Cookie, .Sandwich, .Wrap, .CandyBar, .PopTart, .Water, .FruitJuice, .SportsDrink, .Gum]
        var inventory: [VendingSelection: ItemType]
        var amountDeposited: Double = 10.0
        
        required init(inventory: [VendingSelection : ItemType]) {
            self.inventory = inventory
        }
    func vend(selection: VendingSelection, quantity: Double) throws {
     
        guard var item = inventory[selection] else {
            throw VendingMachineError.invalidSelection
        }
        
        guard item.quantity > 0 else {
            throw VendingMachineError.outOfStock
        }
        
        item.quantity -= quantity
        inventory.updateValue(item, forKey: selection)
        
        let totalPrice = item.price * quantity
        
        if amountDeposited >= totalPrice {
            amountDeposited -= totalPrice
        }else {
            let amountRequired = totalPrice - amountDeposited
            throw VendingMachineError.insufisontFunds(requried: amountRequired)
        }
    
    }
    
    func itemForCurrentSelection(selection: VendingSelection) -> ItemType? {
        return inventory[selection]
        
    }
    
    
    
    func depost(amount: Double) {
        amountDeposited += amount
        
    }
}