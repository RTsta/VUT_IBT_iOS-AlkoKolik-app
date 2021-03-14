//
//  VolumeAlertViewCell.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit

class VolumeAlertViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        self.layer.cornerRadius =  max(self.bounds.size.width,self.bounds.size.height) / 2.0
    }
}
