//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.02.2021.
//

import UIKit


enum ClockHandType {
    case hour
    case minute
    case second
    case none
}


class ClockHand: UIImageView {
    
    private var radius : CGFloat { return min(frame.width, frame.height) }
    lazy var scaleFactor = { return radius / 277.0 * 1.5 }()
    
    let hourHandColor = UIColor.white
    let hourHandLength : CGFloat = 50
    let hourHandWidth : CGFloat = 10
    
    let minuteHandLength : CGFloat = 100
    let minuteHandWidth : CGFloat = 10
    let minuteHandColor = UIColor.white
    
    let secondHandLength : CGFloat = 0.9
    let secondHandWidth : CGFloat = 0.03
    let secondHandColor = UIColor(red: 232/255, green: 60/255, blue: 60/255, alpha: 1.0)
    
    let secondHandCircleDiameter: CGFloat = 4.0
    let handTailLength: CGFloat = 0.0
    var lineWidthFactor: CGFloat = 100.0
    
    let shadowIsOn = false
    
    var diameter: CGFloat { return min(bounds.width, bounds.height) }
    var lineWidth: CGFloat { return diameter / lineWidthFactor }
    var timeValue = 0
    

    lazy var handCenter = { CGPoint(x: radius, y: radius)}()
    
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
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: radius * 2, height: radius * 2))
        
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
    
    func updateHandAngle(angle: CGFloat, duration: Double = 0.5) {
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: { self.transform = CGAffineTransform(rotationAngle: angle) },
                       completion: { (finished: Bool) in
                        return
        })
    }
    
}


class SecondHandCircle: UIImageView {
    
    convenience init(radius: CGFloat, circleDiameter: CGFloat, lineWidth: CGFloat, color: UIColor) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: radius * 2, height: radius * 2))
        let circle: UIImage = renderer.image { (ctx) in
            let rectangle = CGRect(x: radius-circleDiameter * lineWidth/2,
                                   y: radius-circleDiameter * lineWidth/2,
                                   width: circleDiameter * lineWidth,
                                   height: circleDiameter * lineWidth)
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.setStrokeColor(color.cgColor)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        self.init(image: circle)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
