//
//  TodayDrinkTableCell.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 11.03.2021.
//

import UIKit

class TodayDrinkTableCell: UITableViewCell {

    var plusImage : UIImageView = UIImageView(image: UIImage(named: "btn_add_drink_small") ?? UIImage())
    
    var style : buttonStyle = .none  {
        didSet {update()}
    }
    
    @IBOutlet weak var drinkLabel: UILabel!
    
    private func update(){
        self.layer.cornerRadius = min(self.bounds.size.width,self.bounds.size.height) / 4.0
        self.layer.borderWidth = 3.0
        self.layer.borderColor = UIColor.appBackground.cgColor
        switch style {

        case .drink:
            drinkLabel.isHidden = false
        case .add:
            backgroundColor = .appBackground
            self.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(plusImage)
            drinkLabel.isHidden = true
        default:
            drinkLabel.isHidden = true
            backgroundColor = .appBackground
        }
    }
    
    
    enum buttonStyle {
        case drink
        case add
        case none
    }
}
