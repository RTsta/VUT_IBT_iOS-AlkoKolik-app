//
//  TodayDrinkAddTableCell.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 11.03.2021.
//

import UIKit

class TodayDrinkAddTableCell: UITableViewCell {
    
    @IBOutlet weak var plusImage: UIImageView!
    
    override func layoutSubviews() {
        backgroundColor = .appBackground
        self.layer.cornerRadius = min(self.bounds.size.width,self.bounds.size.height) / 4.0
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.appGrey.cgColor
    }
}
