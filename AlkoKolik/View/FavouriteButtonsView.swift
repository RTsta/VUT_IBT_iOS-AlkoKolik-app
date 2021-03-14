//
//  FavouriteButtonsView.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit
// TODO: Načíst user default když se instancuje toto view, aby se správně nakreslil počet tlačítek
class FavouriteButtonsView: UIView {
    
    var numberOfButtons : Int = 3
    var buttons : [UIButton] = [UIButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupButtons()
    }
    
    private func setupView(){
        self.backgroundColor = .clear
    }
    
    func updateFavouriteBtns(){
        //favouriteBtn1.drinkType = .cocktail
    }
    
    private func setupButtons() {

        let btnDiameter : CGFloat = 80.0
        let btnRadius = btnDiameter/2
        let btnGap : CGFloat = 30.0
        
        var x = bounds.midX
        let y = bounds.midY
        
        var button = UIFavouriteDrinkButton(frame: CGRect(x: x-btnRadius, y: y-btnRadius, width: btnDiameter, height: btnDiameter), type: .beer)
        button.setTitle("btn 1", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        buttons.append(button)
        self.addSubview(button)
        
        x = bounds.midX + (btnDiameter + btnGap)
        button = UIFavouriteDrinkButton(frame: CGRect(x: x-btnRadius, y: y-btnRadius, width: btnDiameter, height: btnDiameter), type: .cocktail)
        button.setTitle("btn 2", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        buttons.append(button)
        self.addSubview(button)
        
        x = bounds.midX - (btnDiameter + btnGap)
        button = UIFavouriteDrinkButton(frame: CGRect(x: x-btnRadius, y: y-btnRadius, width: btnDiameter, height: btnDiameter), type: .spirit)
        button.setTitle("btn 3", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        buttons.append(button)
        self.addSubview(button)
    }

    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped ")
        NotificationCenter.default.post(name: .FavouriteBtnTapped, object: nil)
    }
}

extension Notification.Name {
    static var FavouriteBtnTapped: Notification.Name {
        return .init(rawValue: "FavouriteButtonView.ButtonTapped")
    }
}
