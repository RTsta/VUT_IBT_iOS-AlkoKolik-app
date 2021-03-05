//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 23.02.2021.
//

import UIKit

@IBDesignable
class ProgressRing : UIImageView {
    
    private var diameter: CGFloat { return min(bounds.width, bounds.height) }
    private var radius: CGFloat {return diameter/2}
    private lazy var scaleFactor = { return diameter / 277.0 }()
    
    static var trackLineWidth : CGFloat = 30
    static var progressLineWidth : CGFloat = 30
    
    var trackColor: UIColor = .appMax
    var progressRingInsideFillColor: UIColor = .clear
    
    var timeValue = 0.0 //in hours
    var timeDuration = 90.0 //in minutes
    
    private var startAngle: CGFloat { return CGFloat(timeValue * 30.0) }
    private var endAngle: CGFloat { return CGFloat(startAngle) + CGFloat(timeDuration / 60.0) * 30.0 }
    
    convenience init(frame: CGRect, initTimeValue: Double = 0) {
        self.init(frame: frame)
        setup(initTimeValue)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    private func setup(_ initTimeValue: Double = 0) {
        timeValue = initTimeValue
        
        let backgroundRing = drawRingBackground()
        let progressRing = drawProgressRing()
        self.addSubview(UIImageView(image: backgroundRing))
        self.mask = UIImageView(image: progressRing)
        translatesAutoresizingMaskIntoConstraints = false
        transform = CGAffineTransform(rotationAngle: startAngle.radians)
    }
    
    private func drawRingBackground()->UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let cgctx = ctx.cgContext
            let arcRadius = max(radius - (ProgressRing.trackLineWidth * scaleFactor) / 2.0, radius - (ProgressRing.progressLineWidth * scaleFactor) / 2.0)
            cgctx.addArc(center: CGPoint(x: radius, y: radius),
                         radius: arcRadius,
                         startAngle: 0,
                         endAngle: CGFloat.pi * 2,
                         clockwise: false)
            cgctx.setStrokeColor(trackColor.cgColor)
            cgctx.setFillColor(progressRingInsideFillColor.cgColor)
            cgctx.setLineWidth(ProgressRing.trackLineWidth * scaleFactor)
            cgctx.setLineCap(.round)
            cgctx.drawPath(using: .fillStroke)
        }
    }
    
    private func drawProgressRing() -> UIImage {
        let renderer =  UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let cgctx = ctx.cgContext
            let arcRadius = max(radius - (ProgressRing.trackLineWidth*scaleFactor) / 2.0, radius - (ProgressRing.progressLineWidth*scaleFactor) / 2.0)
            
            let angle = endAngle - startAngle
            
            print("time: \(timeValue),start: \(startAngle) end: \(endAngle) angle: \(angle)")
            
            cgctx.addArc(center: CGPoint(x: radius, y: radius),
                            radius: arcRadius,
                            startAngle: startAngle.radians,
                            endAngle: angle.radians,
                            clockwise: false)
            print("scale: \(scaleFactor) diameter: \(diameter)")
            cgctx.setLineCap(.round)
            cgctx.setLineWidth(ProgressRing.progressLineWidth*scaleFactor)
            cgctx.drawPath(using: .stroke)
        }
    }
    
    func updateRingAngle(currentTime: Double, duration: Double = 0.5) {
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.timeValue = currentTime
                        self.mask = UIImageView(image: self.drawProgressRing())
                        self.transform = CGAffineTransform(rotationAngle: (self.startAngle - 70.0).radians)
                        
                       },
                       completion: { (finished: Bool) in
                        return
        })
    }
}

/*###########################################################################################################################*/
//Some helper extensions below
private extension FloatingPoint {    
    func mod(between left: Self, and right: Self, byIncrementing interval: Self) -> Self {
        assert(interval > 0)
        assert(interval <= right - left)
        assert(right > left)
        
        if self >= left, self <= right {
            return self
        } else if self < left {
            return (self + interval).mod(between: left, and: right, byIncrementing: interval)
        } else {
            return (self - interval).mod(between: left, and: right, byIncrementing: interval)
        }
    }
}
