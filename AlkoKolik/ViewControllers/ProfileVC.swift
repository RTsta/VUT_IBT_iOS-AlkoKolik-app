//
//  ProfileVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 03.03.2021.
//

import UIKit
import HealthKit

class ProfileVC: UITableViewController {
    
    var HKManager : HealthKitManager = HealthKitManager()
    let profileDataStore = ProfileDataStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ProfileVC {
    
    func HKauthorization() {
        HKManager.authorizeHealthKit { (authorized, error) in
            print("\(authorized.description) ::: \(error.debugDescription)")
            guard authorized else {
                return
              }
        }
    }
    
    func loadWeight(){
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
          print("Height Sample Type is no longer available in HealthKit")
          return
        }
            
        profileDataStore.getMostRecentSample(for: heightSampleType) { (sample, error) in
              
          guard let sample = sample else {
            if let error = error { print("error \(error)")
            }
            return
          }
              
          //2. Convert the height sample to meters, save to the profile model,
          //   and update the user interface.
          let heightInMeters = sample.quantity.doubleValue(for: HKUnit.meter())
          //self.userHealthProfile.heightInMeters = heightInMeters
          //self.updateLabels()
        }
    }
}
