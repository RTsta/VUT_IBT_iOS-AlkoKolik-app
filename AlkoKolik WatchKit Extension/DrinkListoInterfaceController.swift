//
//  DrinkListoInterfaceController.swift
//  AlkoKolik WatchKit Extension
//
//  Created by Arthur Nácar on 20.03.2021.
//

import WatchKit
import Foundation


class DrinkListoInterfaceController: WKInterfaceController {
    
    var drinks = ListOfDrinksManager.loadAllDrinks()
    @IBOutlet weak var drinkTable: WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let drinks = drinks?.sorted(by: {$0.type < $1.type}) {
            drinkTable.setNumberOfRows(drinks.count, withRowType: "DrinkItemRow")
            for index in 0..<drinkTable.numberOfRows {
                guard let controller = drinkTable.rowController(at: index) as? DrinkRowController else { continue }
                controller.drink = drinks[index]
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if let drinks = drinks {
            let context : [String:Any?] = ["volumes":drinks[rowIndex].volume,
                                           "selectedDrink": drinks[rowIndex]]
            presentController(withName: "VolumeTableIC", context: context)
        }
    }
}
