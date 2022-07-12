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
    
    
    @IBOutlet weak var favouritesViewHeight: NSLayoutConstraint!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var clockView: UIClockView!
    
    var childFavVC : FavouriteButtonsVC? = nil
    
    private var timer : Timer = Timer()
    
    private var duration : Double = 0.0 { didSet {
        updateDurationLabel(duration)
        clockView.ringDuration = duration
    }}
    
    private var soberDate : Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(watchRequestedUpdate), name: .watchRequestedUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadSoberDate), name: .modelCalculated, object: nil)
        startClock()
        model = AppModel()
        if UserDefaultsManager.isFirsttimeLaunch() == false {
            HealthKitManager.authorizeHealthKit { (authorized, error) in
                guard authorized else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: NSLocalizedString("HealthKit", comment: "HealthKit info unavaibile warning"),
                                                      message: NSLocalizedString("Sorry, there is a problem with HelthKit. Please check app premissions on health data", comment: "Sorry, there is a problem with HelthKit. Please check app premissions on health data"),
                                                      preferredStyle: .alert)
                        
                        if let url = URL(string: "x-apple-health://") {
                            if UIApplication.shared.canOpenURL(url) {
                                alert.addAction(UIAlertAction(title: NSLocalizedString("Open Health", comment: "Open Apple Health app"), style: UIAlertAction.Style.default) {_ in
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                })
                            }
                        }

                        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel button title"), style: UIAlertAction.Style.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
            }
            UserNotificationManager.requestAuthorization(actionIfDenied: nil)
        }
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = model
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.updateSimulation(complition: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let favVC = childFavVC?.favCollection{
            favouritesViewHeight.constant = favVC.contentSize.height
        }
        if UserDefaultsManager.isFirsttimeLaunch() == true {
            let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
            if let _walkthroughVC = storyboard.instantiateViewController(identifier: "WalkthroughVC") as? WalkthroughVC{
                UserDefaultsManager.setFirsttimeLaunch(false)
                present(_walkthroughVC, animated: true, completion: nil)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        // Application is back in the foreground
        loadSoberDate()
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

    
    @objc func watchRequestedUpdate(){
        var response : [String:Any] = [:]
        response["currentBAC"] = model.currentBAC
        response["soberDate"] = model.soberDate
        WatchManager.shared.sendMessage(response, replyHandler: nil, errorHandler: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FavouriteButtonsVC {
            vc.model = model
            childFavVC = vc
        }
    }
}
