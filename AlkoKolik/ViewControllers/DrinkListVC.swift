//
//  DrinkListVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit


class DrinkListVC : UIViewController {
    
    var listOfDrinks = [DrinkItem]()
   
    @IBOutlet weak var favouriteBtnsView: UIView!
    @IBOutlet weak var drinksTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _list = loadDrinksFromJSON() {
            listOfDrinks = _list
            drinksTable.reloadData()
        }
        
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

extension DrinkListVC {
    private func loadDrinksFromJSON() -> [DrinkItem]?{
        guard let filePath = Bundle.main.path(forResource: "listOfDrinks", ofType: "json") else {return nil}
        let url = URL(fileURLWithPath: filePath)

        do {
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                guard let drinks = json["drink"] as? [[String: Any]] else {return nil}
                var parsedDrinks = [DrinkItem]()
                for drink in drinks{
                        guard let id = drink["id"] as? Int,
                              let name = drink["name"] as? String,
                              let volumes = drink["volume"] as? [Double],
                              let percentage = drink["percentage"] as? Double,
                              let type = drink["type"] as? String
                        else {return nil}
                        
                        var enumType : DrinkType = .none
                        switch type {
                        case "beer":
                            enumType = .beer
                        case "wine":
                            enumType = .wine
                        case "cider":
                            enumType = .cider
                        case "cocktail":
                            enumType = .cocktail
                        case "liquer":
                            enumType = .liqueur
                        case "vodka", "rum":
                            enumType = .spirit
                        default:
                            break
                        }
                        
                    parsedDrinks.append(DrinkItem(id: id, name: name, volume: volumes, alcoholPercentage: percentage, type: enumType))
                    }
                return parsedDrinks
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
}

