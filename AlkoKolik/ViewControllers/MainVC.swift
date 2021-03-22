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
    
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var clock: UIClockView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    
    
    let HKManager = HealthKitManager()
    let model = AlcoholModel()
    var personalData : AlcoholModel.PersonalData?
    
    var duration : Double = 0.0 { didSet {
        updateDurationLabel(duration)
    }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        HKAuthorization()
        HealthKitManager.getPersonalData(){_h,_w,_a,_s in
            guard let _ = _w,
                  let _ = _h,
                  let _ = _a,
                  let _ = _s
            else {return}
            self.personalData = AlcoholModel.PersonalData(sex: _s!, height: _h!, weight: _w!, age: _a!)
            self.calculateAlcoholModel()
        }
        clock.parrentTickAction = {self.duration -= 1/60}
        clock.startClock()
        NotificationCenter.default.addObserver(self, selector: #selector(calculateAlcoholModel), name: .favouriteBtnPressd, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.calculateAlcoholModel()
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
            durationLabel.text = "\(d > 0 ? String(d)+"d" : "") \(h > 0 ? String(h)+"h" : "") \(m)min"
        }else {
            durationLabel.isHidden = true
        }
    }
    
    @objc func calculateAlcoholModel(){
        guard let _ = personalData else { return }
        
        let from = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let to = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let intervalToCurrent = Calendar.current.dateComponents([.minute], from: from, to: Date())
        
        
        model.run(personalData: personalData!, from: from, to: to) { graphInputs, succes in
            guard succes, let _graphinputs = graphInputs else {return } // TODO: print error
            if (0 <= (intervalToCurrent.minute ?? -1)) && ((intervalToCurrent.minute ?? 0) < _graphinputs.count) {
                for i in intervalToCurrent.minute!..<_graphinputs.count {
                    if _graphinputs[i] == 0 {
                        let timeOfGettingSober = i
                        duration = Double(timeOfGettingSober - intervalToCurrent.minute!)
                        clock.durationTime = duration
                        break
                    }
                }
            }
        }
    }
    
    
    func HKAuthorization() {
        HealthKitManager.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                return // TODO: what error
            }
        }
    }
}

