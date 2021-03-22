//
//  DrinkRowController.swift
//  AlkoKolik WatchKit Extension
//
//  Created by Arthur Nácar on 20.03.2021.
//

import WatchKit

class DrinkRowController: NSObject {
    
    @IBOutlet var separator: WKInterfaceSeparator!
    @IBOutlet var drinkLabel: WKInterfaceLabel!
    
    var drink: DrinkItem? {
      didSet {
        guard let drink = drink else { return }
        // 4
        drinkLabel.setText(drink.name)
        separator.setColor(UIColor.colorFor(drinkType: drink.type))
      }
    }
}
