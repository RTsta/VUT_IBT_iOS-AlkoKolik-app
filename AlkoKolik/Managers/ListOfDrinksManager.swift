//
//  ListOfDrinksManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 11.03.2021.
//

import Foundation

class ListOfDrinksManager {
    
    private static var fileName : String = "listOfDrinks"
    private static var fileType : String = "json"
    
    class func loadAllDrinks() -> [DrinkItem]?{
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) else {return nil}
        let url = URL(fileURLWithPath: filePath)
        
        do {
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let drinks = json["drink"] as? [[String: Any]] else {return nil}
                var parsedDrinks = [DrinkItem]()
                for drink in drinks{
                    guard let id = drink["id"] as? Int,
                          let name = drink["name"] as? String,
                          let volumes = drink["volume"] as? [Double],
                          let percentage = drink["percentage"] as? Double,
                          let type = drink["type"] as? String,
                          let active = drink["active"] as? Bool
                    else {return nil}
                    
                    var enumType : DrinkType = .none
                    switch type {
                    case "beer":
                        enumType = .beer
                    case "wine":
                        enumType = .wine
                    case "cider":
                        enumType = .cider
                    case "cocktail":
                        enumType = .cocktail
                    case "liquer":
                        enumType = .liqueur
                    case "vodka", "rum", "whiskey":
                        enumType = .spirit
                    default:
                        break
                    }
                    if active{
                        parsedDrinks.append(DrinkItem(id: id, name: name, volume: volumes, alcoholPercentage: percentage, type: enumType))
                    }
                }
                return parsedDrinks
            }
        } catch let error as NSError {
            print("ListOfDrinksManager - Error - Failed to load: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
    
    class func findDrink(drink_id: Int) -> DrinkItem?{
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) else {return nil}
        let url = URL(fileURLWithPath: filePath)
        
        do {
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let drinks = json["drink"] as? [[String: Any]] else {return nil}
                for drink in drinks{
                    if let id = drink["id"] as? Int,
                       id == drink_id {
                        guard let name = drink["name"] as? String,
                              let volumes = drink["volume"] as? [Double],
                              let percentage = drink["percentage"] as? Double,
                              let type = drink["type"] as? String
                        else {return nil}
                        var enumType : DrinkType = .none
                        switch type {
                        case "beer":
                            enumType = .beer
                        case "wine":
                            enumType = .wine
                        case "cider":
                            enumType = .cider
                        case "cocktail":
                            enumType = .cocktail
                        case "liquer":
                            enumType = .liqueur
                        case "vodka", "rum", "whiskey":
                            enumType = .spirit
                        default:
                            break
                        }
                        return DrinkItem(id: id, name: name, volume: volumes, alcoholPercentage: percentage, type: enumType)
                    }
                }
            }
        } catch let error as NSError {
            print("ListOfDrinksManager - Error - Failed to load: \(error.localizedDescription)")
        }
        return nil
    }
}
