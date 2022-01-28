//
//  Color.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 26.02.2021.
//

import WatchKit

extension UIColor {
    class var appMax: UIColor { return self.init(named: "appMax") ?? .purple}
    
    class var appSemiMax: UIColor { return self.init(named: "appSemiMax") ?? .purple}
    
    class var appMid: UIColor { return self.init(named: "appMid") ?? .purple}
    
    class var appMin: UIColor { return self.init(named: "appMin") ?? .purple}
    
    class var appGrey: UIColor { return self.init(named: "appGray") ?? .purple }
    
    class var appDarkGrey: UIColor { return self.init(named: "appDarkGray") ?? .purple }
    
    class var appWhite: UIColor { return self.init(named: "appWhite") ?? .white }
    
    class var appBackground: UIColor { return self.init(named: "appBackground") ?? .black }
    
    class var appText: UIColor { return self.init(named: "appText") ?? .white }
    
    class func colorFor(drinkType: DrinkType) -> UIColor {
        switch drinkType {
        case .beer:
            return self.appMin
        case .wine, .cider:
            return self.appMid
        case .liqueur:
            return self.appSemiMax
        case .spirit, .cocktail, .vodka, .rum, .whiskey, .gin, .tequila:
            return self.appMax
        default:
            return self.yellow
        }
    }
    
    //based on http://www.szu.cz/uploads/documents/szu/aktual/zprava_tabak_alkohol_cr_2019.pdf
    //dávky jsou kombinací SZU a WHO
    class func colorFor(daydose: Double, gender:PersonalData.Gender) -> UIColor {
        if gender == .male {
            switch daydose {
            case 0:
                return self.appGrey
            case 0..<24:
                return self.appMin
            case 24..<40:
                return self.appMid
            case 40..<60:
                return self.appSemiMax
            case 60...:
                return self.appMax
            default:
                return .clear
            }
        }else { //female
            switch daydose {
            case 0:
                return self.appGrey
            case 0..<16:
                return self.appMin
            case 16..<27:
                return self.appMid
            case 27..<40:
                return self.appSemiMax
            case 40...:
                return self.appMax
            default:
                return .clear
            }
        }
    }
}
