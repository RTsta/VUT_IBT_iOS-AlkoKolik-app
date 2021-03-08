//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 23.02.2021.
//

import UIKit

class ProgressRing : ClockComponent {
    
    var timeValue = 0.0 //in hours
    public var timeDuration : TimeInterval = 0 * 60.0//in minutes and converted to sec
    
    private var startAngle: CGFloat { return CGFloat(timeValue * 30.0) }
    private var angle: CGFloat {return CGFloat(timeDuration / 3600.0 * 30)}
    
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
        let progressRing = drawProgressRing()
        let bcg = UIImageView(image: drawRingBackground())
        bcg.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bcg)
        image = progressRing
        translatesAutoresizingMaskIntoConstraints = false
        transform = CGAffineTransform(rotationAngle: startAngle.radians)
    }
    
    private func drawRingBackground()->UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { ctx in
            let cgctx = ctx.cgContext
            let arcRadius = radius /*- (progressLineWidth * scaleFactor / 2.0)*/
            cgctx.addArc(center: viewCenter,
                         radius: arcRadius,
                         startAngle: 0,
                         endAngle: CGFloat.pi * 2,
                         clockwise: false)
            cgctx.setStrokeColor(UIColor.clear.cgColor)
            cgctx.setFillColor(UIColor.clear.cgColor)
            //cgctx.setLineWidth(progressLineWidth * scaleFactor)
            cgctx.setLineCap(.round)
            cgctx.drawPath(using: .fillStroke)
        }
    }
    
    private func drawProgressRing() -> UIImage {
        let renderer =  UIGraphicsImageRenderer(size: viewSize)
        return renderer.image { ctx in
            let cgctx = ctx.cgContext
            let arcRadius = radius - (progressLineWidth * scaleFactor / 2.0)
            print("\(bounds.size) arcRadius \(arcRadius)")
            cgctx.addArc(center: super.viewCenter,
                            radius: arcRadius,
                            startAngle: CGFloat(-90.0).radians,
                            endAngle: (angle-90.0).radians,
                            clockwise: false)
            cgctx.setLineCap(.butt)
            cgctx.setStrokeColor(progressLineColor.cgColor)
            cgctx.setLineWidth(progressLineWidth*scaleFactor)
            cgctx.drawPath(using: .stroke)
        }
    }
    private func update(){
        if timeDuration > 0 {
            self.image = drawProgressRing()
            //TODO
            //self.transform = self.transform.rotated(by: (self.startAngle).radians)
            self.transform = CGAffineTransform(rotationAngle: (self.startAngle).radians)
        } else {
            self.image = nil
        }
    }
    
    public func updateRingAngle(currentTime: Double, animated: Bool ,duration: Double = 0.5) {
        if animated {
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           options: .curveEaseInOut,
                        animations: {
                            self.timeValue = currentTime
                            if self.timeDuration > 0 { self.timeDuration -= 1 }
                            self.update()
                        },
                        completion: { (finished: Bool) in
                            return
                        })
        } else {
            self.update()
        }
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
