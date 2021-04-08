//
//  VolumeAlertViewCell.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit

class VolumeAlertViewCell: UICollectionViewCell {
    
    var isFavourite : Bool = false
    
    override var isHighlighted: Bool {
        didSet {
            toggleIsHighlighted()
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var favouriteIcon: UIView!
    
    override func layoutSubviews() {
        self.circleView.layer.cornerRadius = max(self.bounds.size.width,self.bounds.size.height) * 0.5
        setupFavouriteIcon()
        if isFavourite {
            favouriteIcon.isHidden = false
        }
    }
    
    func setupFavouriteIcon(){
        favouriteIcon.layer.cornerRadius = max(favouriteIcon.bounds.size.width,favouriteIcon.bounds.size.height) * 0.5
        favouriteIcon.backgroundColor = .appDarkGrey
        favouriteIcon.isHidden = true
        
    }
    
    func toggleIsHighlighted() {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut], animations: {
            self.alpha = self.isHighlighted ? 0.8 : 1.0
            self.transform = self.isHighlighted ?
                CGAffineTransform.identity.scaledBy(x: 0.97, y: 0.97) :
                CGAffineTransform.identity
        })
    }
}
