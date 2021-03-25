//
//  FavouriteButtonsView.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit
// TODO: Načíst user default když se instancuje toto view, aby se správně nakreslil počet tlačítek
class FavouriteButtonsVC: UIViewController {
    var willNeedReloadFavourites = true
    var favourites : [FavouriteDrink]? /* { didSet{ updateFavouriteBtns() }}*/
    var fullDrinkItems : [DrinkItem] = []
    
    var parentVC : UIViewController?
    
    @IBOutlet weak var favCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favouritesNeedsReload), name: .favouriteNeedsReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(watchRequestedUpdate), name: .watchRequestedUpdate, object: nil)
        if willNeedReloadFavourites || (favourites == nil){
            initFavourites()
            willNeedReloadFavourites = false
        }
        
        loadFullDrinkItems()
        favCollection.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }
    
    func initFavourites(){
        favourites = UserDefaultsManager.loadFavouriteDrinks()
        if favourites == nil {
            favourites = []
        }
    }
    
    func loadFullDrinkItems(){
        guard let fav = favourites else { fatalError("favourtites shoud be initialized")}
        var items : [DrinkItem] = []
        for drink in fav {
            let elem = ListOfDrinksManager.findDrink(drink_id: drink.drinkId)
                ?? DrinkItem(id: -1, name: "", volume: [0], alcoholPercentage: 0, type: .none)
            items.append(elem)
        }
        fullDrinkItems = items
    }
    
    @objc func favouritesNeedsReload(){
        willNeedReloadFavourites = true
        reload()
    }
    
    func reload(){
        if willNeedReloadFavourites {
            initFavourites()
            loadFullDrinkItems()
            willNeedReloadFavourites = false
            favCollection.reloadData()
        }
    }
    
    @objc func handleShortPress(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let touchPoint = sender.location(in: favCollection)
            if let indexPath = favCollection.indexPathForItem(at: touchPoint){
                
                let row = indexPathToArrayNumber(indexPath: indexPath)
                let drink = fullDrinkItems[row]
                let volume = favourites![row].volume
                
                
                CoreDataManager.insertRecord(drink: drink, volumeOpt: row, time: Date(), volumeMl: volume)
                NotificationCenter.default.post(name: .favouriteBtnPressd, object: nil)
            }
        }
    }
    
    @objc func watchRequestedUpdate(){
        if let favourites = favourites {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(favourites)
                var response : [String:Any] = [:]
                response["favourites"] = data
                WatchManager.shared.sendMessage(response, replyHandler: nil, errorHandler: nil)
            }catch let error { print("FavouriteButtonsVC - Error - \(error.localizedDescription)")}
        }
    }
}

// MARK: CollectionView
extension FavouriteButtonsVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollection(){
        self.view.backgroundColor = .clear
        self.favCollection.backgroundColor = .clear
        
        let shortPress = UITapGestureRecognizer(target: self, action: #selector(self.handleShortPress))
        favCollection.addGestureRecognizer(shortPress)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = favourites?.count ?? 0
        switch count {
        case 1...3:
            return count
        case 4:
            return 2
        case 5:
            if section == 0 {return 3}
            else { return 2}
        case 6:
            return 3
        case 7:
            if section == 1 {return 3}
            else { return 2}
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favouriteDrinkCell", for: indexPath) as? UIFavouriteDrinkCell
        else {fatalError("Cell is not an instance of VolumeAlertView.")}
        cell.drinkType = fullDrinkItems[indexPathToArrayNumber(indexPath: indexPath)].type
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidth: CGFloat = flowLayout.itemSize.width
        let cellSpacing: CGFloat = flowLayout.minimumInteritemSpacing
        var cellCount = CGFloat(collectionView.numberOfItems(inSection: section))
        var collectionWidth = collectionView.frame.size.width
        var totalWidth: CGFloat
        if #available(iOS 11.0, *) {
            collectionWidth -= collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right
        }
        repeat {
            totalWidth = cellWidth * cellCount + cellSpacing * (cellCount - 1)
            cellCount -= 1
        } while totalWidth >= collectionWidth
        
        if (totalWidth > 0) {
            let edgeInset = (collectionWidth - totalWidth) / 2
            return UIEdgeInsets.init(top: flowLayout.sectionInset.top, left: edgeInset, bottom: flowLayout.sectionInset.bottom, right: edgeInset)
        } else {
            return flowLayout.sectionInset
        }
    }
    
    private func indexPathToArrayNumber(indexPath: IndexPath) -> Int{
        let count = favourites?.count ?? 0
        switch count {
        case 1, 2, 3:
            return indexPath.row
        case 4:
            if indexPath.section == 0{
                return indexPath.row
            }else {
                return indexPath.row+2
            }
        case 5:
            if indexPath.section == 0{
                return indexPath.row
            }else {
                return indexPath.row+3
            }
        case 6:
            if indexPath.section == 0{
                return indexPath.row
            }else {
                return indexPath.row+3
            }
        case 7:
            if indexPath.section == 0{
                return indexPath.row
            }else if indexPath.section == 1{
                return indexPath.row+2
            } else {
                return indexPath.row + 5
            }
        default:
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = favourites?.count ?? 0
        switch count {
        case 1...3:
            return 1
        case 4...6:
            return 2
        case 7:
            return 3
        default:
            return 0
        }
    }
}
