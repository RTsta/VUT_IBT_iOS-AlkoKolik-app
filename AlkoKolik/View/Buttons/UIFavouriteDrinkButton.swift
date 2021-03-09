//
//  FavouriteDrinkButton.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 27.02.2021.
//

import UIKit

class UIFavouriteDrinkButton: UIButton {
    
    var drinkType : DrinkType = .none {
        didSet {
            update()
        }
    }
    
    private var scaleFactor : CGFloat { frame.height/80.0 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init(frame: CGRect, type: DrinkType){
        super.init(frame: frame)
        drinkType = type
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup(){
        //let icon
        self.layer.cornerRadius = max(self.bounds.size.width,self.bounds.size.height) / 2.0
        update()
        self.setNeedsDisplay()
    }
    
    private func update() {
        switch drinkType {
        case .beer:
            self.setImage(UIImage(named: "btn_beer")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = .appGrey
            backgroundColor = .appMin
        case .wine:
            self.setImage(UIImage(named: "btn_wine")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = .appGrey
            backgroundColor = .appMid
        case .cider:
            backgroundColor = .appMid
        case .liqueur:
            backgroundColor = .appSemiMax
        case .spirit:
            self.setImage(UIImage(named: "btn_spirit")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = .appGrey
            backgroundColor = .appMax
        case .cocktail:
            self.setImage(UIImage(named: "btn_cocktail")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.tintColor = .appGrey
            backgroundColor = .appSemiMax
        default:
            backgroundColor = .yellow
        }
    }
}
