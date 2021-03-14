//
//  DrinkListCell.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 01.03.2021.
//

import UIKit

class DrinkListCell: UITableViewCell {
    var type : DrinkType = .none {
        didSet {update()}
    }
    @IBOutlet weak var icon: UIView!
    @IBOutlet weak var labelText: UILabel!
    
    func update(){
        icon.layer.cornerRadius = 0.5 * max(icon.bounds.size.width, icon.bounds.size.height)
        icon.backgroundColor = UIColor.colorFor(drinkType: self.type)
    }
}
