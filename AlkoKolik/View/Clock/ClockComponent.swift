//
//  ClockComponent.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 06.03.2021.
//

import UIKit

class ClockComponent: UIImageView {
    //ring
    var diameter : CGFloat { return min(bounds.width,bounds.height) }
    var radius: CGFloat {return diameter/2}
    lazy var viewCenter : CGPoint = {return CGPoint(x: radius, y: radius)}()
    lazy var viewSize : CGSize = {CGSize(width: diameter, height: diameter)}()
    lazy var scaleFactor : CGFloat = { return diameter / 277.0 }()
    
    var progressLineWidth : CGFloat = 20
    var progressLineColor : UIColor = .appMax
    
    var trackColor: UIColor = .appMax
    
    //face
    var markOffset : CGFloat = 10.0
    
    let minuteMarkLength : CGFloat = 17.0
    let minuteMarkWidth : CGFloat = 2.0
    let minuteMarkColor : UIColor = .appGrey
    
    let fiveMinuteMarkLength : CGFloat = 22.0
    let fiveMinuteMarkWidth : CGFloat = 3.0
    let fiveMinuteMarkColor : UIColor = .appWhite
    
    let hourHandColor : UIColor = .appWhite
    let hourHandLength : CGFloat = 50.0 * 0.7
    let hourHandWidth : CGFloat = 10.0
    
    let minuteHandLength : CGFloat = 100.0 * 0.7
    let minuteHandWidth : CGFloat = 10.0
    let minuteHandColor : UIColor = .appWhite
    
    let secondHandLength : CGFloat = 0.9
    let secondHandWidth : CGFloat = 0.03
    let secondHandColor : UIColor = UIColor(red: 232/255, green: 60/255, blue: 60/255, alpha: 1.0)
    
    let handTailLength: CGFloat = 0.0

    lazy var handCenter = { CGPoint(x: radius, y: radius)}()
    
}
