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
        switch self.type {
        case .beer:
            icon.backgroundColor = .appMin
        case .wine:
            icon.backgroundColor = .appMid
        case .cider:
            icon.backgroundColor = .appMid
        case .liqueur:
            icon.backgroundColor = .appSemiMax
        case .spirit:
            icon.backgroundColor = .appMax
        case .cocktail:
            icon.backgroundColor = .appMax
        default:
            backgroundColor = .yellow
        }
    }
}
