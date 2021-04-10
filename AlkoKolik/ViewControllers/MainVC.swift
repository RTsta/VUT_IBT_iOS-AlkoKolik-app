//
//  ViewController.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 08.02.2021.
//

import UIKit
import CoreData
import HealthKit

class MainVC: UIViewController {
    lazy var model : AppModel = { return (tabBarController as? MainTabBarController)?.model ?? createNewAppModel()}()
    
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var clockView: UIClockView!
    
    private var timer : Timer = Timer()
    
    private var duration : Double = 0.0 { didSet {
        updateDurationLabel(duration)
        clockView.ringDuration = duration
    }}
    
    private var soberDate : Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(watchRequestedUpdate), name: .watchRequestedUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadSoberDate), name: .modelCalculated, object: nil)
        startClock()
        HKAuthorization()
        model = AppModel()
        
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = model
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.update(complition: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - TIMER
    private func startClock() {
        if timer.isValid {
            timer.invalidate()
        }
        let refreshInterval : TimeInterval = 1.0
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc private func tick() {
        let realTimeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
        clockView.localTime = UIClockView.LocalTime(hour: realTimeComponents.hour ?? 10,
                                                    minute:  realTimeComponents.minute ?? 42,
                                                    second: realTimeComponents.second ?? 0)
    }
    
    @objc private func loadSoberDate(){
        
        // TODO: předělat
        if let _sober = model.soberDate {
            let intervalToSober = Calendar.current.dateComponents([.minute], from: Date(), to: _sober)
            if let min = intervalToSober.minute,
               min > 0{
                duration = Double(min)
            } else {
                duration = 0
            }
        }
    }
    
    private func createNewAppModel() -> AppModel{
        let new = AppModel()
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = new
        }
        return new
    }
    
    private func updateDurationLabel(_ timeDuration : Double){
        if (timeDuration > 0){
            let d =  Int(timeDuration / 60 / 24)
            let h = Int(timeDuration / 60 - Double(d) * 24.0)
            let m = Int(timeDuration - Double(d) * 24.0 * 60.0 - Double(h)*60)
            durationLabel.isHidden = false
            durationLabel.text = "\(d > 0 ? String(d)+"d" : "") \(h > 0 ? String(h)+"h" : "") \(m)min"
        }else {
            durationLabel.isHidden = true
        }
    }
    
    
    func HKAuthorization() {
        HealthKitManager.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                print("not authorized")
                return // TODO: what error
            }
        }
    }
    
    @objc func watchRequestedUpdate(){
        var response : [String:Any] = [:]
        response["currentBAC"] = model.currentBAC
        response["soberDate"] = model.soberDate
        WatchManager.shared.sendMessage(response, replyHandler: nil, errorHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FavouriteButtonsVC {
            vc.model = model
        }
    }
}
