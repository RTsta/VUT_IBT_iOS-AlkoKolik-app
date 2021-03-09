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
    
    class var appBackgroundDark: UIColor { return self.init(red:136/255.0, green:242/255.0, blue:174/255.0, alpha: 1.0) }
}
