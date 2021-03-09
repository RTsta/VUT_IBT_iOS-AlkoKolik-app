//
//  FavouriteButtonsView.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit

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
        let btnGap : CGFloat = 30.0
        
        var x = (frame.width - (3 * btnDiameter + 2 * btnGap)) * 0.5
        let y = (frame.height - 1 * 80 + 0 * 30) / 2
        
        var button = UIFavouriteDrinkButton(frame: CGRect(x: x, y: y, width: btnDiameter, height: btnDiameter), type: .beer)
        button.setTitle("btn 1", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        buttons.append(button)
        self.addSubview(button)
        
        x = x + (btnDiameter + btnGap)
        button = UIFavouriteDrinkButton(frame: CGRect(x: x, y: y, width: btnDiameter, height: btnDiameter), type: .cocktail)
        button.setTitle("btn 2", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        buttons.append(button)
        self.addSubview(button)
        
        x = x + (btnDiameter + btnGap)
        button = UIFavouriteDrinkButton(frame: CGRect(x: x, y: y, width: btnDiameter, height: btnDiameter), type: .spirit)
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
