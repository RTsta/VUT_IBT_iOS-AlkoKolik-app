//
//  DrinkListContainerVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 16.06.2021.
//

import UIKit


class DrinkListContainerVC : UITableViewController {
    enum Usage {
        case drinkList
        case addDrink
        case customDrinks
    }
    
    weak var delegate: DrinkListVCDelegate?
    
    var containerUsage: DrinkListContainerVC.Usage = .drinkList
    
    lazy var model : AppModel = { return (tabBarController as? MainTabBarController)?.model ?? createNewAppModel()}()
    var childFavVC : FavouriteButtonsVC? = nil
    
    private var listOfDrinks = [[DrinkItem]]()
    private var categoriesOfDrinks = [DrinkType]()
    var selectedIndexPath : IndexPath = IndexPath()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadListOfDrinks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadListOfDrinks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func createNewAppModel() -> AppModel{
        let new = AppModel()
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = new
        }
        return new
    }
    
    private func loadListOfDrinks(){
        var result : [[DrinkItem]] = []
        var drinks = containerUsage == .customDrinks ? model.customDrinks : model.listOfAllDrinks
        drinks = drinks.filter({$0.active == true})
        drinks.sort(by: {$0.name < $1.name})
        drinks.sort(by: {model.isCustom(drink: $0) && !model.isCustom(drink: $1 )})
        drinks.sort(by: {$0.type < $1.type})
        
        var cat = Set<DrinkType>()
        for drink in drinks { cat.insert(drink.type) }
        categoriesOfDrinks = Array(cat).sorted(by: { $0.text() < $1.text() })
        
        for _ in categoriesOfDrinks { result.append( [DrinkItem]() ) }
        
        for drink in drinks {
            result[categoryToInt(drink.type)].append(drink)
        }
        
        listOfDrinks = result
        self.tableView.reloadData()
    }
    
    private func categoryToInt(_ elem: DrinkType) -> Int{
        return categoriesOfDrinks.firstIndex(of: elem) ?? 0
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfDrinks[section].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfDrinks.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return categoriesOfDrinks.map{$0.firstLetter()}
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        categoriesOfDrinks[section].text()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "drinkListCell", for: indexPath) as? DrinkListCell else { fatalError("Cell is not an instance of DrinkListCell.") }
        
        let oneDrink = listOfDrinks[indexPath.section][indexPath.row]
            cell.type = oneDrink.type
            cell.labelText.text = oneDrink.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let drink = listOfDrinks[selectedIndexPath.section][selectedIndexPath.row]
        delegate?.didSelectedDrink(drink)
        if containerUsage != .addDrink{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        delegate?.didDeselectDrink()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.appBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.appText
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if containerUsage == .customDrinks {
            return .delete
        }else {
            return .none
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if containerUsage == .customDrinks {
                tableView.beginUpdates()
                let drink = listOfDrinks[indexPath.section][indexPath.row]
                CoreDataManager.updateCustomDrinks(of: drink, active: false)
                listOfDrinks[indexPath.section].remove(at: indexPath.row)
                model.updateCustomDrinks()
                model.favourites.removeAll(where: {($0.drinkId == drink.id)})
                UserDefaultsManager.saveFavourite(drinks: model.favourites)
                NotificationCenter.default.post(name: .favouriteNeedsReload, object: nil)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        }
    }
}
