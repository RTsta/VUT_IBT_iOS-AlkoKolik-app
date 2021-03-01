//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.02.2021.
//

import UIKit


class ClockFace: UIImageView {
    
    private var staticClockFaceImage: UIImage?
    private var diameter: CGFloat { return min(frame.width, frame.height) }
    
    lazy var scaleFactor = { return diameter / 277.0 }()
    
    let minuteMarkLength = CGFloat(17.0)
    let minuteMarkWidth = CGFloat(3.0)
    let minuteMarkColor = UIColor(red: 119/255, green: 135/255, blue: 139/255, alpha: 1.0).cgColor
    let fiveMinuteMarkLength = CGFloat(22.0)
    let fiveMinuteMarkWidth = CGFloat(4.0)
    let fiveMinuteMarkColor = UIColor.white.cgColor
    var markOffset = CGFloat(4.0/2.0)
    
    let perimeterFillColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0).cgColor
    let perimeterBorderWidth = CGFloat(5.0)
    let perimeterBorderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0).cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    convenience init(frame: CGRect, staticClockFaceImage: UIImage?) {
        self.init(frame: frame)
        self.staticClockFaceImage = staticClockFaceImage
        setup()
    }
    
    
    func setup() {
        markOffset = CGFloat(max(ProgressRing.trackLineWidth, ProgressRing.progressLineWidth) * scaleFactor + 4.0/2.0*scaleFactor)
        image = staticClockFaceImage ?? drawClockFace()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    func drawClockFace() -> UIImage {
        //let perimeter = drawPerimeter()
        let marks = drawMarks()

        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { (ctx) in
            let origin = CGPoint(x: 0, y: 0)
            //perimeter.draw(at: origin)
            marks.draw(at: origin)
        }
    }
    
    
    func drawPerimeter() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { (ctx) in
            let rectangle = CGRect(x: perimeterBorderWidth*scaleFactor/2.0, y: perimeterBorderWidth*scaleFactor/2.0, width: diameter-perimeterBorderWidth*scaleFactor, height: diameter-perimeterBorderWidth*scaleFactor)
            ctx.cgContext.setFillColor(perimeterFillColor)
            ctx.cgContext.setStrokeColor(perimeterBorderColor)
            ctx.cgContext.setLineWidth(perimeterBorderWidth*scaleFactor)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }
    
    func drawMarks() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { (ctx) in
            ctx.cgContext.translateBy(x: diameter/2, y: diameter/2)
            ctx.cgContext.setLineCap(.round)
            let startPoint = CGPoint(x: diameter/2-markOffset*scaleFactor, y: 0)
            for mark in 0..<60 {
                ctx.cgContext.move(to: startPoint)
                var endPoint = CGPoint(x: startPoint.x - minuteMarkLength * scaleFactor, y: 0)
                ctx.cgContext.setLineWidth(minuteMarkWidth * scaleFactor)
                ctx.cgContext.setStrokeColor(minuteMarkColor)
                
                if mark % 5 == 0 {
                    ctx.cgContext.setStrokeColor(fiveMinuteMarkColor)
                    ctx.cgContext.setLineWidth(fiveMinuteMarkWidth * scaleFactor)
                    endPoint = CGPoint(x: startPoint.x - fiveMinuteMarkLength * scaleFactor, y: 0)
                }
                ctx.cgContext.addLine(to: endPoint)
                
                ctx.cgContext.drawPath(using: .fillStroke)
                ctx.cgContext.rotate(by: CGFloat(Double.pi/30))
            }
        }
    }
}
