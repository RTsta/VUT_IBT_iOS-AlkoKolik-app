//
//  FavouriteDrinkButton.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 27.02.2021.
//

import UIKit

class UIFavouriteDrinkCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    
    var drinkType : DrinkType = .none
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    
    private func setup(){
        self.layer.cornerRadius = max(self.bounds.size.width,self.bounds.size.height) / 2.0
        self.tintColor = .appGrey
        
        self.backgroundColor = UIColor.colorFor(drinkType: self.drinkType)
        switch drinkType {
        case .beer:
            icon.image = UIImage(named: "btn_beer")?.withRenderingMode(.alwaysTemplate)
        case .wine, .cider:
            icon.image = UIImage(named: "btn_wine")?.withRenderingMode(.alwaysTemplate)
        case .spirit, .liqueur:
            icon.image = UIImage(named: "btn_spirit")?.withRenderingMode(.alwaysTemplate)
        case .cocktail:
            icon.image = UIImage(named: "btn_cocktail")?.withRenderingMode(.alwaysTemplate)
        default:
            break
        }
    }
}
