//
//  DrinkListVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit


class DrinkListVC : UIViewController {
    
    @IBOutlet weak var favouritesViewHeight: NSLayoutConstraint!
    lazy var model : AppModel = { return (tabBarController as? MainTabBarController)?.model ?? createNewAppModel()}()
    var childFavVC : FavouriteButtonsVC? = nil
    
    private var listOfDrinks = [DrinkItem]()
    var selectedRow = 0
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var drinksTable: UITableView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustFavouriteCollectionHeight), name: .favouriteNeedsReload, object: nil)
        loadListOfDrinks()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        adjustFavouriteCollectionHeight()
    }
    
    private func createNewAppModel() -> AppModel{
        let new = AppModel()
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = new
        }
        return new
    }
    
    private func loadListOfDrinks(){
        listOfDrinks = model.listOfDrinks
        listOfDrinks.sort(by: {$0.type < $1.type})
        drinksTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VolumeAlertVC {
            vc.volumesArray = listOfDrinks[selectedRow].volume
            vc.selectedDrink = listOfDrinks[selectedRow]
            vc.cellColor = UIColor.colorFor(drinkType: listOfDrinks[selectedRow].type)
            vc.model = model
            vc.callback = {self.adjustFavouriteCollectionHeight(animated: true)}
        }
        if let vc = segue.destination as? FavouriteButtonsVC {
            vc.model = model
            childFavVC = vc
        }
    }
    
    @objc func adjustFavouriteCollectionHeight(animated: Bool = false){
        if let favVC = childFavVC?.favCollection,
           favouritesViewHeight.constant != favVC.contentSize.height
           {
            favouritesViewHeight.constant = favVC.contentSize.height
            if animated {
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            } else {self.view.layoutIfNeeded()}
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
        selectedRow = indexPath.row
        performSegue(withIdentifier: "alertShowSegue", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

