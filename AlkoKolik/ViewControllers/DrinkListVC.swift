//
//  DrinkListVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit


class DrinkListVC : UIViewController {
    
    var listOfDrinks : [DrinkItem] = [DrinkItem(name: "Vodka", volume: 50.0, alcoholPercentage: 0.39, type: .spirit),
                                      DrinkItem(name: "Beer1", volume: 50.0, alcoholPercentage: 0.39, type: .beer),
                                      DrinkItem(name: "Wine", volume: 50.0, alcoholPercentage: 0.39, type: .wine),
                                      DrinkItem(name: "Rum", volume: 50.0, alcoholPercentage: 0.39, type: .spirit),
                                      DrinkItem(name: "Rum2", volume: 50.0, alcoholPercentage: 0.39, type: .spirit)]
   
    @IBOutlet weak var favouriteBtnsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension DrinkListVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfDrinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "drinkListCell", for: indexPath) as? DrinkListCell else { fatalError("Cell is not an instance of DrinkListCell.") }
        
        let oneDrink = listOfDrinks[indexPath.row]
        cell.type = oneDrink.type
        cell.labelText.text = oneDrink.name
        
        return cell
    }
    
    
}

