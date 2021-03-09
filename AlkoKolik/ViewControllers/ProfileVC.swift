//
//  ProfileVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 03.03.2021.
//

import UIKit
import HealthKit

class ProfileVC: UITableViewController {
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeightAndHeight()
    }
}

extension ProfileVC {
    
    func loadWeightAndHeight(){
        HealthKitManager.getHeight() { (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    print("error in loading height")
                }
                return
            }
            let heightInCM = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
            self.heightLabel.text = String(heightInCM)
            
        }
        
        HealthKitManager.getWeight() { (sample, error) in
            guard let sample = sample else {
                if let error = error {
                    print("error in loading weight")
                }
                return
            }
            
            let weightInKG = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            self.weightLabel.text = String(weightInKG)
        }
        
    }
}
