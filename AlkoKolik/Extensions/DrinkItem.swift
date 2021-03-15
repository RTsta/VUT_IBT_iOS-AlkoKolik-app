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
}

enum DrinkType: Comparable {
    case beer
    case wine
    case cider
    case liqueur
    case spirit
    case mixeddrink
    case cocktail
    case none
}
