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
    
    open var localTime = LocalTime()
    open var timer = Timer()
    
    private var progressRing = UIImageView()
    private var clockFace = UIImageView()
    private var hourHand = ClockHand(frame: CGRect(), type: .none)
    private var minuteHand = ClockHand(frame: CGRect(), type: .none)
    //private var secondHand = ClockHand()
    private var secondHandCircle = UIImageView()
    
    
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
        setupProgressRing()
        setupHands()
        setupClockFace()
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
        //    clockFace = ClockFace(frame: self.frame, staticClockFaceImage: UIImage(named: "clockface"))
        
        addSubview(progressRing)
        addSubview(clockFace)
        addSubview(hourHand)
        addSubview(minuteHand)
        //addSubview(secondHand)
        addSubview(secondHandCircle)
        
        clockFace.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        clockFace.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        clockFace.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        clockFace.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true
        
        hourHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        hourHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        hourHand.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        hourHand.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true
        
        minuteHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        minuteHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        minuteHand.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        minuteHand.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true
        
        progressRing.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
        progressRing.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
        progressRing.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
        progressRing.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true
        
        /*
         secondHand.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
         secondHand.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
         secondHand.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
         secondHand.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true
         
         secondHandCircle.centerXAnchor.constraint(equalTo: clockFace.centerXAnchor).isActive = true
         secondHandCircle.centerYAnchor.constraint(equalTo: clockFace.centerYAnchor).isActive = true
         secondHandCircle.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor).isActive = true
         secondHandCircle.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor).isActive = true
         */
    }
    
    func startClock() {
        if timer.isValid {
            timer.invalidate()
            return
        }
        
        let refreshInterval : TimeInterval = 1.0
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc private func tick() {
        let localTimeComponents: Set<Calendar.Component> = [.hour, .minute, .second]
        let realTimeComponents = Calendar.current.dateComponents(localTimeComponents, from: Date())
        localTime.second = realTimeComponents.second ?? 0
        localTime.minute = realTimeComponents.minute ?? 10
        localTime.hour = realTimeComponents.hour ?? 10
        
        updateHands()
        updateRing()
    }
    
    private func updateHands() {
        //secondHand.updateHandAngle(angle: CGFloat(Double(localTime.second * 6) * translateToRadian))
        minuteHand.updateHandAngle(angle: CGFloat(Double(localTime.minute * 6).radians))
        let hourDegree = Double(localTime.hour) * 30.0 + Double(localTime.minute) * 0.5
        hourHand.updateHandAngle(angle: CGFloat(hourDegree.radians))
    }
    
    private func updateRing(){
        guard let _progressRing = progressRing as? ProgressRing else {fatalError("ring not initialized")}
        let accurateHour = Double(localTime.hour % 12) + Double(localTime.minute) * 100.0 / 60.0 / 100.0
        print("acurate \(accurateHour)")
        _progressRing.updateRingAngle(currentTime: accurateHour)
    }
}


extension UIClockView: UIGestureRecognizerDelegate {}
