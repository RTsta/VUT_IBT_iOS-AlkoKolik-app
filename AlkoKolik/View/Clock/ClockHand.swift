//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.02.2021.
//

import UIKit


class ClockHand: ClockComponent {
    
    enum ClockHandType {
        case hour
        case minute
        case second
        case none
    }
    

    var timeValue = 0
    
    convenience init(frame: CGRect, type: ClockHandType, initTimeValue: Double = 0) {
        self.init(frame: frame)
        setup(type: type, Int(initTimeValue))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup(type: .none)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(type: .none)
    }
    
    override func prepareForInterfaceBuilder() {
        setup(type: .minute)
    }
    
    func setup(type: ClockHandType,_ initTime: Int = 0) {
        switch type {
        case .hour:
            timeValue = (initTime % 24) * 30
            image = drawHourHand()
        case .minute:
            timeValue = (initTime % 60) * 6
            image = drawMinuteHand()
        case .second:
            timeValue = (initTime % 24) * 6
            //image = drawSecondHand()
        default:
            return
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        transform = CGAffineTransform(rotationAngle: CGFloat(Double(timeValue) * Double.pi/180.0)) //set the initial hand position, where initialValue == 60.0 is "15 min"
    }
    
    
    func drawHourHand() -> UIImage{
        let _length = hourHandLength * scaleFactor
        let _width = hourHandWidth * scaleFactor
        let _handTail = handTailLength * scaleFactor
        
        let renderer = UIGraphicsImageRenderer(size:super.viewSize)
        
        let startPoint = CGPoint(x: handCenter.x, y: handCenter.y-_length)
        let endPoint = CGPoint(x: handCenter.x, y: handCenter.y+_handTail)
        
        return renderer.image { (ctx) in
            ctx.cgContext.move(to: startPoint)
            ctx.cgContext.addLine(to: endPoint)
            
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineWidth(_width)
            ctx.cgContext.setFillColor(hourHandColor.cgColor)
            ctx.cgContext.setStrokeColor(hourHandColor.cgColor)
            
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }
    
    func drawMinuteHand() -> UIImage{
        let _length = minuteHandLength * scaleFactor
        let _width = minuteHandWidth * scaleFactor
        let _handTail = handTailLength * scaleFactor
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: radius * 2, height: radius * 2))
        
        let startPoint = CGPoint(x: handCenter.x, y: handCenter.y-_length)
        let endPoint = CGPoint(x: handCenter.x, y: handCenter.y+_handTail)
        
        return renderer.image { (ctx) in
            ctx.cgContext.move(to: startPoint)
            ctx.cgContext.addLine(to: endPoint)
            
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineWidth(_width)
            ctx.cgContext.setFillColor(minuteHandColor.cgColor)
            ctx.cgContext.setStrokeColor(minuteHandColor.cgColor)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }
    
    
    
    func updateHandAngle(angle: CGFloat,animated: Bool ,duration: Double = 0.5) {
        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: { self.transform = CGAffineTransform(rotationAngle: angle) },
                           completion: { (finished: Bool) in
                            return
                           })
        }else {
            self.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
}
