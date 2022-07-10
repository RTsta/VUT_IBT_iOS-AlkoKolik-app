//
//  CustomDrinksListVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 08.07.2022.
//

import Foundation
import UIKit
class CustomDrinksListVC: UIViewController, DrinkListVCDelegate {
    var model : AppModel?
    var selectedDrink: DrinkItem?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DrinkListContainerVC {
            vc.delegate = self
            vc.model = model!
            vc.containerUsage = .customDrinks
        }
        if let vc = segue.destination as? OneCustomDrinkTableVC {
            vc.model = model!
            vc.drink = selectedDrink
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func didSelectedDrink(_ drink: DrinkItem?) {
        selectedDrink = drink
        performSegue(withIdentifier: "one_custom_drink_segue", sender: nil)
    }
    
    func didDeselectDrink() {
        return
    }
    
    
}
