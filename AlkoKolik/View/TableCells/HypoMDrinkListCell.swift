//
//  HypoMDrinkListCell.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 21.06.2021.
//

import UIKit

class HypoMDrinkListCell: DrinkListCell {

    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    weak var delegate : HypoMDrinkListCellDelegate?
    var drink_id = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        volumeButton.addTarget(self, action: #selector(volumeButtonPressed), for: .touchUpInside)
        expandButton.addTarget(self, action: #selector(expandButtonPressed), for: .touchUpInside)
    }
    
    @objc private func volumeButtonPressed(){
        delegate?.volumeButtonPressed(withId: drink_id)
    }
    
    @objc private func expandButtonPressed(){
        delegate?.expandButtonPressed(at: drink_id)
    }

}
