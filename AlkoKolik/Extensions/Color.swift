//
//  Color.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 26.02.2021.
//

import UIKit

extension UIColor {
    class var appMax: UIColor { return self.init(named: "appMax") ?? .systemPink}
    
    class var appSemiMax: UIColor { return self.init(named: "appSemiMax") ?? .systemPink}
    
    class var appMid: UIColor { return self.init(named: "appMid") ?? .systemPink}
    
    class var appMin: UIColor { return self.init(named: "appMin") ?? .systemPink}
    
    class var appGrey: UIColor { return self.init(named: "appGray") ?? .systemPink }
    
    class var appDarkGrey: UIColor { return self.init(named: "appDarkGray") ?? .systemPink }
    
    class var appWhite: UIColor { return self.init(named: "appWhite") ?? .white }
    
    class var appBackground: UIColor { return self.init(named: "appBackground") ?? .black }
    
    class var appText: UIColor { return self.init(named: "appText") ?? .white }
    
    class func colorFor(drinkType: DrinkType) -> UIColor {
        switch drinkType {
        case .beer:
            return self.appMin
        case .wine:
            return self.appMid
        case .cider:
            return self.appMid
        case .liqueur:
            return self.appSemiMax
        case .spirit:
            return self.appMax
        case .cocktail:
            return self.appMax
        default:
            return self.yellow
        }
    }
    
    class func colorFor(daydose: Double) -> UIColor {
        switch daydose {
        case 0:
            return self.appGrey
        case 0..<20:
            return self.appMin
        case 20..<30:
            return self.appMid
        case 30..<40:
            return self.appSemiMax
        case 40...:
            return self.appMax
        default:
            return .clear
        }
    }
}
