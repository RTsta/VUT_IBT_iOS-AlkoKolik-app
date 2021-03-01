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
            backgroundColor = .appMin
        case .wine:
            backgroundColor = .appMid
        case .cider:
            backgroundColor = .appMid
        case .liqueur:
            backgroundColor = .appSemiMax
        case .spirit:
            backgroundColor = .appMax
        case .cocktail:
            self.setImage(drawCocktail(), for: .normal)
            backgroundColor = .appMax
        default:
            backgroundColor = .yellow
        }
    }
    
    private func drawBeer() -> UIImage{
         
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 5, height: 5))
        return renderer.image {ctx in
        }
    }
    
    private func drawCocktail() -> UIImage {
        let size = CGSize(width: min(frame.width,frame.height), height: min(frame.width,frame.height))
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cgctx = ctx.cgContext

            cgctx.translateBy(x: 0.5*(frame.width-27*scaleFactor), y: 0.5*(frame.height-40.5*scaleFactor))
            cgctx.move(to: CGPoint(x: 0, y: 0))
            cgctx.addLine(to: CGPoint(x: 27, y: 0))
            cgctx.addLine(to: CGPoint(x: 13.5, y: 16))
            cgctx.addLine(to: CGPoint(x: 0, y: 0))
            
            cgctx.move(to: CGPoint(x: 13.5, y: 16))
            cgctx.addLine(to: CGPoint(x: 13.5, y: 40.5))
            
            cgctx.move(to: CGPoint(x: 5, y: 40.5))
            cgctx.addLine(to: CGPoint(x: 21, y: 40.5))
            
            
            cgctx.scaleBy(x: scaleFactor, y: scaleFactor)
            cgctx.setLineWidth(2)
            cgctx.setStrokeColor(UIColor.appGrey.cgColor)
            cgctx.setLineCap(.square)
            cgctx.drawPath(using: .stroke)
        }
    }
}
