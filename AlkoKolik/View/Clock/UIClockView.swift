//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.02.2021.
//

import UIKit

class ClockCAShapeLayer: CAShapeLayer {
    open var predesignedLineWidth : CGFloat = 1.0
    open override var frame: CGRect {
        didSet{
            let scaleFactor = min(frame.height,frame.height)/300
            self.lineWidth = predesignedLineWidth * scaleFactor
        }
    }
}

class UIClockView: UIView {
    
    struct LocalTime {
        var hour : Int
        var minute : Int
        var second : Int
    }
    
    var localTime : LocalTime = LocalTime(hour: 0, minute: 0, second: 0) {
        didSet {
            //duration of animation
            let hourDuration : Double = Double((abs(oldValue.hour % 12 - localTime.hour % 12) + abs(oldValue.minute - localTime.minute)/60) / 2)
            let minuteDuration : Double = Double(abs(oldValue.minute - localTime.minute)/10)

            if oldValue.minute != localTime.minute {
                rotateHourHandAnimated(toValue: CGFloat((localTime.hour % 12)) * 30.0 + CGFloat(localTime.minute)*0.5 , withDuration: hourDuration)
                rotateMinuteHandAnimated(toValue: CGFloat(localTime.minute) * 6.0, withDuration: minuteDuration)
            }
            if localTime.minute % 60 == 0 {
                animateRingMinuteDown()
            }
        }
    }
    
    var ringDuration : Double = 0 {
        didSet {
            animateRingUpdate(from: oldValue, to: ringDuration)
        }
    }
    
    private var clockHandsBoundsIsSet : Bool = false
    
    init(){
        super.init(frame: .zero)
        setup()
        backgroundColor = UIColor.clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let exactHour : CGFloat = CGFloat((components.hour ?? 0) % 12) + CGFloat((components.minute ?? 0)) / 60.0
        backgroundRingLayer.frame = bounds
        backgroundRingLayer.path = createRingPath(inside: backgroundRingLayer.bounds,
                                                  startHourAngle: (exactHour * 30.0).radians)
        
        watchMinuteFaceLayer.frame = bounds
        watchMinuteFaceLayer.path = createMinuteMarksPath(inside: watchMinuteFaceLayer.bounds)
        
        watchHourFaceLayer.frame = bounds
        watchHourFaceLayer.path = createHourMarksPath(inside: watchHourFaceLayer.bounds)
        
        /* load frame only once at begining for rotation transformation
         https://stackoverflow.com/questions/55853620/calayers-transforming-incorrectly-when-rotated */
        if !clockHandsBoundsIsSet {
            hourHandLayer.frame = bounds
            minuteHandLayer.frame = bounds
            clockHandsBoundsIsSet = true
        }
        hourHandLayer.path = createHourHandPath(inside: hourHandLayer.bounds)
        
        minuteHandLayer.path = createMinuteHandPath(inside: minuteHandLayer.bounds)
    }
    
    //strokeEnd will be adjusted to determin duration
    private lazy var backgroundRingLayer : ClockCAShapeLayer = {
        let layer = ClockCAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.appMax.cgColor
        layer.predesignedLineWidth = 25
        layer.lineWidth = layer.predesignedLineWidth
        layer.strokeStart  = 0 // 0%
        layer.strokeEnd = 0     //100%
        return layer
    }()
    
    private lazy var watchMinuteFaceLayer : ClockCAShapeLayer = {
        let layer = ClockCAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.appGrey.cgColor
        layer.lineCap = .round
        layer.predesignedLineWidth = 3
        layer.lineWidth = layer.predesignedLineWidth
        return layer
    }()
    
    private lazy var watchHourFaceLayer : ClockCAShapeLayer = {
        let layer = ClockCAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.appWhite.cgColor
        layer.lineCap = .round
        layer.predesignedLineWidth = 4
        layer.lineWidth = layer.predesignedLineWidth
        return layer
    }()
    
    private lazy var hourHandLayer : ClockCAShapeLayer = {
        let layer = ClockCAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.appWhite.cgColor
        layer.lineCap = .round
        layer.predesignedLineWidth = 10
        layer.lineWidth = layer.predesignedLineWidth
        return layer
    }()
    
    private lazy var minuteHandLayer : ClockCAShapeLayer = {
        let layer = ClockCAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.appWhite.cgColor
        layer.lineCap = .round
        layer.predesignedLineWidth = 10
        layer.lineWidth = layer.predesignedLineWidth
        return layer
    }()
    
    
    func setup(){
        layer.addSublayer(watchMinuteFaceLayer)
        layer.addSublayer(watchHourFaceLayer)
        layer.addSublayer(backgroundRingLayer)
        layer.addSublayer(hourHandLayer)
        layer.addSublayer(minuteHandLayer)
    }
    
    func createRingPath(inside square: CGRect, startHourAngle: CGFloat) -> CGPath{
        let radius = min(square.height,square.height)/2
        let path = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0),
                                radius: radius - backgroundRingLayer.lineWidth/2,
                                startAngle: 0,
                                endAngle:  2 * .pi,
                                clockwise: true)
        path.apply(CGAffineTransform(rotationAngle: CGFloat(-90.0.radians) + startHourAngle))
        path.apply(CGAffineTransform(translationX: radius, y: radius))
        
        return path.cgPath
    }
    
    func createMinuteMarksPath(inside square: CGRect) -> CGPath{
        let minuteMarkLength : CGFloat = 18.0
        
        let markOffset : CGFloat = 5.0
        let radius = min(square.height,square.height)/2
        let scaleFactor = 2*radius / 300
        
        let path = UIBezierPath()
        let startPoint = CGPoint(x: 150 - (25 + markOffset), y: 0)
        for _ in 0..<60{
            path.move(to: startPoint)
            let endPoint = CGPoint(x: startPoint.x - minuteMarkLength, y: 0) //mínus délka ručičky
            path.addLine(to: endPoint)
            path.apply(CGAffineTransform(rotationAngle: -.pi*2/60))
        }
        path.apply(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        path.apply(CGAffineTransform(translationX: square.center.x, y: square.center.y))

        return path.cgPath
    }
    
    func createHourMarksPath(inside square: CGRect) -> CGPath{
        
        let fiveMinuteMarkLength : CGFloat = 20.0

        let radius = min(square.height,square.height)/2
        let scaleFactor = 2*radius / 300
        
        let markOffset : CGFloat = 5.0
        
        let path = UIBezierPath()
        let startPoint = CGPoint(x: 150 - (25 + markOffset), y: 0)
        for _ in 0..<12{
            path.move(to: startPoint)
            let endPoint = CGPoint(x: startPoint.x - fiveMinuteMarkLength, y: 0) //mínus délka ručičky
            path.addLine(to: endPoint)
            path.apply(CGAffineTransform(rotationAngle: -.pi*2/12))
        }
        path.apply(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        path.apply(CGAffineTransform(translationX: square.center.x, y: square.center.y))
        
        
        return path.cgPath
    }
    
    func createHourHandPath(inside square: CGRect) -> CGPath{
        let hourHandLength : CGFloat = 45.0

        let radius = min(square.height,square.height)/2
        let scaleFactor = 2*radius / 300
        
        let path = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: 0)
        path.move(to: startPoint)
        let endPoint = CGPoint(x: 0, y: -hourHandLength) // délka ručičky
        path.addLine(to: endPoint)
        path.apply(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        path.apply(CGAffineTransform(translationX: square.center.x, y: square.center.y))
        return path.cgPath
    }
    
    func createMinuteHandPath(inside square: CGRect) -> CGPath{
        let minuteHandLength : CGFloat = 90.0

        let radius = min(square.height,square.height)/2
        let scaleFactor = 2*radius / 300

        let path = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: 0)
        path.move(to: startPoint)
        let endPoint = CGPoint(x: 0, y: -minuteHandLength) // délka ručičky
        path.addLine(to: endPoint)
        path.apply(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
        path.apply(CGAffineTransform(translationX: square.center.x, y: square.center.y))
        return path.cgPath
    }
    
    func animateRingMinuteDown() {
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.duration = 1.0
        animation.repeatCount = 1
        animation.byValue = 1/60
        backgroundRingLayer.strokeStart += 1/60
        backgroundRingLayer.add(animation, forKey: animation.keyPath)
    }
    
    //animation for added duration to the ring
    func animateRingUpdate(from: Double, to: Double){
        let difference = to - from
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration =  Double(abs(difference) / 120) // duration of appearing 2 hours will be 1 sec
        animation.repeatCount = 1
        animation.fromValue = backgroundRingLayer.strokeEnd
        animation.toValue = backgroundRingLayer.strokeEnd + CGFloat(difference * 1/720) //1 min is 0.0013%
        
        
        backgroundRingLayer.strokeStart = 0.0
        backgroundRingLayer.strokeEnd = CGFloat(to * 1/720) // 100% of stroke means 12 hours
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let exactHour : CGFloat = CGFloat((components.hour ?? 0) % 12) + CGFloat((components.minute ?? 0)) / 60.0
        
        backgroundRingLayer.path = createRingPath(inside: backgroundRingLayer.bounds,
                                                  startHourAngle: (exactHour * 30.0).radians)
        backgroundRingLayer.add(animation, forKey: animation.keyPath)
    }
    
    func rotateMinuteHandAnimated(toValue rotation: CGFloat, withDuration duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = duration
        animation.repeatCount = 1
        animation.fromValue = minuteHandLayer.transform
        animation.toValue = CATransform3DMakeRotation(rotation.radians, 0, 0, 1.0)
        
        minuteHandLayer.transform = CATransform3DMakeRotation(rotation.radians, 0, 0, 1.0)
        minuteHandLayer.add(animation, forKey: nil)
    }
    
    func rotateHourHandAnimated(toValue rotation: CGFloat, withDuration duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = duration
        animation.repeatCount = 1
        animation.fromValue = hourHandLayer.transform
        animation.toValue = CATransform3DMakeRotation(rotation.radians, 0, 0, 1.0)
        
        hourHandLayer.transform = CATransform3DMakeRotation(rotation.radians, 0, 0, 1.0)
        hourHandLayer.add(animation, forKey: nil)
    }
    
    
}
