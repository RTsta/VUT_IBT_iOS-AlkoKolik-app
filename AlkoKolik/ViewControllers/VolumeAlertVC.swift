//
//  VolumeAlertView.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit

class VolumeAlertVC: UIViewController {
    
    var selectedDrink : DrinkItem?
    var volumesArray : [Double] = []
    var cellColor : UIColor = .appGrey
    
    @IBOutlet weak var theView: UIView!
    @IBOutlet weak var collection: UICollectionView!
    
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.allowsSelection = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theView.layer.cornerRadius = theView.bounds.width / 10.0
    }
    
}

// MARK: CollectionView
extension VolumeAlertVC: UICollectionViewDelegate, UICollectionViewDataSource {
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
        cell.label.text = ("\(Int(volumesArray[indexPathToArrayNumber(indexPath: indexPath)])) ml")
        cell.backgroundColor = cellColor
        return cell
        
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
        case 4, 5:
            if indexPath.section == 0{
                return indexPath.row
            }else {
                return indexPath.row+2
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
    
    func centerItemsInCollectionView(cellWidth: Double, numberOfItems: Double, spaceBetweenCell: Double, collectionView: UICollectionView) -> UIEdgeInsets {
        let totalWidth = cellWidth * numberOfItems
        let totalSpacingWidth = spaceBetweenCell * (numberOfItems - 1)
        let leftInset = (collectionView.frame.width - CGFloat(totalWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }
}
