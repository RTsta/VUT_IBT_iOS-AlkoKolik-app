//
//  DrinkListVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit


class DrinkListVC : UIViewController {
    
    var listOfDrinks = [DrinkItem]()
    var selectedRow = 0
    
    @IBOutlet weak var favouriteBtnsView: UIView!
    @IBOutlet weak var drinksTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _list = ListOfDrinksManager.loadAllDrinks() {
            listOfDrinks = _list
            drinksTable.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VolumeAlertVC {
            vc.volumesArray = listOfDrinks[selectedRow].volume
            vc.selectedDrink = listOfDrinks[selectedRow]
            vc.cellColor = UIColor.colorFor(drinkType: listOfDrinks[selectedRow].type)
        }
    }
    
}

// MARK: UITableView
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        selectedRow = indexPath.row
        performSegue(withIdentifier: "alertShowSegue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

