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
        case "vodka", "rum", "whiskey", "gin", "tequila":
            return .spirit
        default:
            return .none
        }
    }
}

enum DrinkType: Comparable {
    case beer
    case wine
    case cider
    case liqueur
    case spirit
    case cocktail
    case none
}
