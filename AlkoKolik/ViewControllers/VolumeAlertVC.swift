//
//  VolumeAlertView.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit

class VolumeAlertVC: UIViewController {
    
    var selectedDrink : DrinkItem?             //currently selected drink
    var volumesArray : [Double] = []           //array of volume options of drink
    var cellColor : UIColor = .appGrey
    
    var favourites : [FavouriteDrink]?         //array of favourite drinks from UserDefaults
    var favouriteVolumes : [Double] = []       //list of volumes that relates to the drink (favoirites[x] = favouriteVolumes[x]
    
    var callback : (() -> Void)?
    var afterFavouritesChanged : (() -> Void)?
    var model : AppModel? = nil 
    
    
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        let tapGestureOutside = UITapGestureRecognizer(target: self, action: #selector(self.pressOutsideCollection))
        self.view.addGestureRecognizer(tapGestureOutside)
        
        initFavourites()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theView.layer.cornerRadius = theView.bounds.width / 8.0
        
        loadVolumesOfFavourite()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //collectionHeightConstraint.constant = collection.contentSize.height
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callback?()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func initFavourites(){
        favourites = model?.favourites
    }
    
    func loadVolumesOfFavourite(){
        
        if let _favourites = favourites,
           let _selected = selectedDrink {
            for f in _favourites {
                if f.drinkId == _selected.id {
                    favouriteVolumes.append(f.volume)
                    if !volumesArray.contains(f.volume) {
                        volumesArray.append(f.volume)
                    }
                }
            }
        }
    }
    
    func reloadeVolumes(){
        if let _list = DefaultDrinksManager.loadAllDrinks(),
           let _selected = selectedDrink,
           let _elem = _list.first(where: {($0.id == _selected.id)}) {
            volumesArray = _elem.volume
        }
    }
    
    @objc func pressOutsideCollection(sender: UITapGestureRecognizer){
        if sender.state == UITapGestureRecognizer.State.ended{
            if !theView.point(inside: sender.location(in: theView), with: nil){
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: CollectionView
extension VolumeAlertVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionView(){
        collection.allowsSelection = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        collection.addGestureRecognizer(longPress)
        
        let shortPress = UITapGestureRecognizer(target: self, action: #selector(self.handleShortPress))
        collection.addGestureRecognizer(shortPress)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch volumesArray.count {
        case 1...3:
            return volumesArray.count
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "drinkVolumeCell", for: indexPath) as? VolumeAlertViewCell
        else {fatalError("Cell is not an instance of VolumeAlertView.")}
        let volume = volumesArray[indexPathToArrayNumber(indexPath: indexPath)]
        if favouriteVolumes.contains(volume){
            cell.isFavourite = true
        } else {cell.isFavourite = false}
        cell.label.text = ("\(Int(volumesArray[indexPathToArrayNumber(indexPath: indexPath)])) ml")
        cell.circleView.backgroundColor = cellColor
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? VolumeAlertViewCell
        cell?.isHighlighted = true
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch volumesArray.count {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let drink = selectedDrink else { return }
        
        CoreDataManager.insertRecord(drink: drink,
                                     volumeOpt: indexPathToArrayNumber(indexPath: indexPath),
                                     time: Date())
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func indexPathToArrayNumber(indexPath: IndexPath) -> Int{
        switch volumesArray.count {
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
    
    // MARK: Collection appearance
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
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: collection)
            if let indexPath = collection.indexPathForItem(at: touchPoint),
               let drink = selectedDrink{
                let row = indexPathToArrayNumber(indexPath: indexPath)
                let pressedVolume = volumesArray[row]
                //drink is not in favourite and it will be added
                if !favouriteVolumes.contains(pressedVolume) {
                    if let f = favourites, f.count >= 7 {return}
                    UserDefaultsManager.insertIntoFavourite(drinkId: drink.id, volume: pressedVolume)
                    favouriteVolumes.append(pressedVolume)
                } else {
                    if (favourites == nil) { initFavourites() }
                    favouriteVolumes.removeAll(where: {$0 == pressedVolume})
                    favourites?.removeAll(where: {($0.drinkId == drink.id && $0.volume == pressedVolume)})
                    UserDefaultsManager.saveFavourite(drinks: favourites!)
                    reloadeVolumes()
                }
                collection.reloadData()
                collection.layoutIfNeeded()
                NotificationCenter.default.post(name: .favouriteNeedsReload, object: nil)
            }
        }
    }
    
    @objc func handleShortPress(sender: UITapGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.ended {
            let touchPoint = sender.location(in: collection)
            if let indexPath = collection.indexPathForItem(at: touchPoint),
               let drink = selectedDrink{
                let row = indexPathToArrayNumber(indexPath: indexPath)
                
                CoreDataManager.insertRecord(drink: drink, volumeOpt: row, time: Date())
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
}
