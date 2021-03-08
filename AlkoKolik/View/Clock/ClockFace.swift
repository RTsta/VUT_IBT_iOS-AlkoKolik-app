//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.02.2021.
//

import UIKit


class ClockFace: ClockComponent {
    
    private var staticClockFaceImage: UIImage?
    
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
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    func setup() {
        image = staticClockFaceImage ?? drawMarks()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func drawMarks() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: viewSize)
        return renderer.image { (ctx) in
            let cgctx = ctx.cgContext
            cgctx.translateBy(x: diameter/2, y: diameter/2)
            cgctx.setLineCap(.round)
            let startPoint = CGPoint(x: diameter/2-markOffset*scaleFactor - progressLineWidth*scaleFactor, y: 0)
            for mark in 0..<60 {
                cgctx.move(to: startPoint)
                var endPoint = CGPoint(x: startPoint.x - minuteMarkLength * scaleFactor, y: 0)
                cgctx.setLineWidth(minuteMarkWidth * scaleFactor)
                cgctx.setStrokeColor(minuteMarkColor.cgColor)
                
                if mark % 5 == 0 {
                    cgctx.setStrokeColor(fiveMinuteMarkColor.cgColor)
                    cgctx.setLineWidth(fiveMinuteMarkWidth * scaleFactor)
                    endPoint = CGPoint(x: startPoint.x - fiveMinuteMarkLength * scaleFactor, y: 0)
                }
                cgctx.addLine(to: endPoint)
                
                cgctx.drawPath(using: .fillStroke)
                cgctx.rotate(by: CGFloat(Double.pi/30))
            }
        }
    }
}
