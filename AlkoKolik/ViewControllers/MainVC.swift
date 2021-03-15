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
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    
    
    
    let HKManager = HealthKitManager()
    
    var duration : Double = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        HKAuthorization()
        
        clock.startClock()
        clock.durationTime = duration
        updateDurationLabel(duration)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favouriteBtnMainSegue" {
            if let vc = segue.destination as? FavouriteButtonsVC{
                vc.parentVC = self
                vc.view.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        containerView.heightAnchor.constraint(equalToConstant: container.preferredContentSize.height).isActive = true
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
    
    
    func HKAuthorization() {
        HealthKitManager.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                return
              }
        }
    }
}

