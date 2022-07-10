//
//  DrinkItem.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import Foundation

struct DrinkItem {
    let id : Int
    let name : String
    let volume : [Double] //volume in ml
    let alcoholPercentage : Double
    let type : DrinkType
    let active : Bool
    
    static func createFrom(_ drink: CustomDrink) -> Self? {
        guard let _volumes = drink.volumes,
              let _name = drink.name,
              let _type = drink.type else {return nil}
        return DrinkItem(id: Int(drink.drink_id), name: _name, volume: _volumes, alcoholPercentage: drink.percentage, type: DrinkType.getType(withName: _type),active: drink.active)
    }
    
    static func createFrom(_ drinks: [CustomDrink]) -> [Self] {
        var result : [Self] = []
        for drink in drinks {
            if let _drink = self.createFrom(drink) {
                result.append(_drink)
            }
        }
        return result
    }
}

enum DrinkType: Comparable, Hashable{
    case beer
    case wine
    case cider
    case liqueur
    case spirit
    case vodka
    case rum
    case whiskey
    case gin
    case tequila
    case cocktail
    case none
    
    func text () -> String {
        switch self {
        case .beer:
            return NSLocalizedString("Beer", comment: "Beer DrinkType localized name")
        case .wine:
            return NSLocalizedString("Wine", comment: "Wine DrinkType localized name")
        case .cider:
            return NSLocalizedString("Cider", comment: "Cider DrinkType localized name")
        case .liqueur:
            return NSLocalizedString("Liqueur", comment: "Liqueur DrinkType localized name")
        case .spirit:
            return NSLocalizedString("Spirit", comment: "Spirit DrinkType localized name")
        case .cocktail:
            return NSLocalizedString("Cocktail", comment: "Cocktail DrinkType localized name")
        case .vodka:
            return NSLocalizedString("Vodka", comment: "Vodka DrinkType localized name")
        case .rum:
            return NSLocalizedString("Rum", comment: "Rum DrinkType localized name")
        case .whiskey:
            return NSLocalizedString("Whiskey", comment: "Whiskey DrinkType localized name")
        case .gin:
            return NSLocalizedString("Gin", comment: "Gin DrinkType localized name")
        case .tequila:
            return NSLocalizedString("Tequila", comment: "Tequila DrinkType localized name")
        case .none:
            return ""
        }
    }
    
    static func getType(withName: String) -> DrinkType {
        switch withName {
        case "beer":
            return .beer
        case "wine", "aperitive":
            return .wine
        case "cider":
            return .cider
        case "cocktail":
            return .cocktail
        case "liquer":
            return .liqueur
        case "spirit":
            return .spirit
        case "vodka":
            return .vodka
        case "rum":
            return .rum
        case "whiskey":
            return .whiskey
        case "gin":
            return .gin
        case "tequila":
            return .tequila
        default:
            return .none
        }
    }
    
    func getString() -> String {
        switch self{
        case .none:
            return ""
        case .beer:
            return "beer"
        case .wine:
            return "wine"
        case .cider:
            return "cider"
        case .liqueur:
            return "liqueur"
        case .spirit:
            return "spirit"
        case .cocktail:
            return "cocktail"
        case .vodka:
            return "vodka"
        case .rum:
            return "rum"
        case .whiskey:
            return "whiskey"
        case .gin:
            return "gin"
        case .tequila:
            return "tequila"
        }
    }
    
    
    
    static func allTypes() -> [DrinkType]{
        return [.beer, .wine, .cider, .liqueur, .spirit, .vodka, .rum, .whiskey, .gin, .tequila, .cocktail, .none]
    }
    
    func firstLetter () -> String {
        if let char = self.text().first {
            return String(char)
        } else { return ""}
    }
}
