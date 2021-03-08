//
//  ProgressRing.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.02.2021.
//

import UIKit


@IBDesignable
class UIClockView: UIView {
    
    public struct LocalTime {
        var hour: Int = 10
        var minute: Int = 10
        var second: Int = 25
    }
    
    var localTime = LocalTime()
    var timer = Timer()
    
    //duratin in minutes
    public var durationTime = 0.0 {didSet {
        guard let _pr = progressRing as? ProgressRing else {return}
        _pr.timeDuration = durationTime * 60
    }}
    
    private var progressRing = ClockComponent()
    private var clockFace = ClockComponent()
    private var hourHand = ClockHand(frame: CGRect(), type: .none)
    private var minuteHand = ClockHand(frame: CGRect(), type: .none)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        autoresizesSubviews = false
        setupProgressRing()
        setupHands()
        setupClockFace()
        
        addSubview(progressRing)
        addSubview(clockFace)
        addSubview(hourHand)
        addSubview(minuteHand)
        
        clockFace.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        clockFace.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        hourHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        hourHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        
        minuteHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        minuteHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        
        progressRing.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        progressRing.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
    }
    
    private func setupHands() {
        hourHand = ClockHand(frame: frame, type: .hour, initTimeValue: Double(localTime.hour * 30))
        minuteHand = ClockHand(frame: frame, type: .minute, initTimeValue: Double(localTime.minute * 6))
    }
    
    private func setupProgressRing(){
        progressRing = ProgressRing(frame: frame, initTimeValue: Double(localTime.hour))
    }
    
    private func setupClockFace() {
        clockFace = ClockFace(frame: frame)
    }
    
    func startClock() {
        if timer.isValid {
            timer.invalidate()
        }
        
        let refreshInterval : TimeInterval = 1.0
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc private func tick() {
        
        let localTimeComponents: Set<Calendar.Component> = [.hour, .minute, .second]
        let realTimeComponents = Calendar.current.dateComponents(localTimeComponents, from: Date())
        localTime.second = realTimeComponents.second ?? 0
        localTime.minute = realTimeComponents.minute ?? 42
        localTime.hour = realTimeComponents.hour ?? 10
        updateHands(animated: true)
        updateRing(animated: true)
    }
    
    private func updateHands(animated: Bool) {
        minuteHand.updateHandAngle(angle: CGFloat(Double(localTime.minute * 6).radians), animated: animated)
        let hourDegree = Double(localTime.hour) * 30.0 + Double(localTime.minute) * 0.5
        hourHand.updateHandAngle(angle: CGFloat(hourDegree.radians), animated: animated)
    }
    
    private func updateRing(animated: Bool){
        guard let _progressRing = progressRing as? ProgressRing else {fatalError("ring not initialized")}
        let accurateHour = Double(localTime.hour % 12) + Double(localTime.minute) * 100.0 / 60.0 / 100.0
        _progressRing.updateRingAngle(currentTime: accurateHour, animated: animated)
        
    }
    
    func updateView(){
        updateRing(animated: true)
    }
}


extension UIClockView: UIGestureRecognizerDelegate {}
