//
//  ViewController.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 08.02.2021.
//

import UIKit
import CoreData

class MainVC: UIViewController {

    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var clock: UIClockView!
    @IBOutlet weak var favouriteBtnsView: FavouriteButtonsView!
    
    let HKManager = HealthKitManager()
    
    var duration : Double = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FavouriteBtnTapped),
                                               name: .FavouriteBtnTapped,
                                               object: nil)
        
        HKAuthorization()
        
        clock.startClock()
        clock.durationTime = duration
        updateDurationLabel(duration)
        
    }
    
    func updateDurationLabel(_ timeDuration : Double){
        if (timeDuration > 0){
            let d =  Int(timeDuration / 60 / 24)
            let h = Int(timeDuration / 60 - Double(d) * 24.0)
            let m = Int(timeDuration - Double(d) * 24.0 * 60.0 - Double(h)*60)
            durationLabel.isHidden = false
            durationLabel.text = "\(d > 0 ? String(d)+"d" : "") \(h > 0 ? String(h)+"h" : "") \(m)m"
        }else {
            durationLabel.isHidden = true
        }
    }
    
    @objc private func FavouriteBtnTapped(_ notification: Notification) {
        duration += 10.25
        clock.durationTime = duration
        updateDurationLabel(duration)
        clock.updateView()
        
        CoreDataManager.insertRecord(drink: DrinkItem(id: 14, name: "Martini bianco", volume: [100, 200], alcoholPercentage: 15.0, type: .wine), volumeOpt: 0, time: Date())
    }
    
    func HKAuthorization() {
        HealthKitManager.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                return
              }
        }
    }
}

