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
    @IBOutlet weak var collectionHeightConstr: NSLayoutConstraint!
    
    
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        
        let tapGestureOutside = UITapGestureRecognizer(target: self, action: #selector(self.pressOutsideCollection))
        self.view.addGestureRecognizer(tapGestureOutside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        theView.layer.cornerRadius = theView.bounds.width / 10.0
    }
    /*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = collection.collectionViewLayout.collectionViewContentSize.height
        collectionHeightConstr.constant = height
        self.view.layoutIfNeeded()
    }*/
    
    
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
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let touchPoint = sender.location(in: collection)
            if let indexPath = collection.indexPathForItem(at: touchPoint) {
                let row = indexPathToArrayNumber(indexPath: indexPath)
                print("\(selectedDrink) a \(volumesArray[row])")
                
            }
        }
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
        cell.label.text = ("\(Int(volumesArray[indexPathToArrayNumber(indexPath: indexPath)])) ml")
        cell.circleView.backgroundColor = cellColor
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
}
