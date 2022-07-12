//
//  DrinkListVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit


class DrinkListVC : UIViewController, DrinkListVCDelegate {

    lazy var model : AppModel = { return (tabBarController as? MainTabBarController)?.model ?? createNewAppModel()}()
    
    var selectedDrink : DrinkItem?
    
    var childFavVC : FavouriteButtonsVC? = nil // TODO: to je divný
    
    @IBOutlet weak var favouritesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var favouritesContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(adjustFavouriteCollectionHeight), name: .favouriteNeedsReload, object: nil)
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? VolumeAlertVC,
           let drink = selectedDrink{
            vc.volumesArray = drink.volume
            vc.selectedDrink = drink
            vc.cellColor = UIColor.colorFor(drinkType: drink.type)
            vc.model = model
            vc.callback = {self.adjustFavouriteCollectionHeight(animated: true)}
        }
        if let vc = segue.destination as? FavouriteButtonsVC {
            vc.model = model
            childFavVC = vc
        }
        if let vc = segue.destination as? DrinkListContainerVC {
            vc.delegate = self
            vc.model = model
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
    
    func didSelectedDrink(_ drink: DrinkItem?) {
        selectedDrink = drink
        performSegue(withIdentifier: "alertShowSegue", sender: nil)
    }
    
    func didDeselectDrink() {
        return
    }
}

