//
//  HealthKitManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 20.02.2021.
//

import Foundation
import HealthKit

class HealthKitManager{
    
    class func insertBAC(weight: Double ,completion: @escaping (Bool, Error?) -> Void = {_,_ in }){
        guard let bacType = HKQuantityType.quantityType(forIdentifier: .bloodAlcoholContent) else {
            fatalError("Data type BAC is no longer part of healthkit")
        }
        let bacQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .none), doubleValue: weight)
        
        let date = Date()
            
        let bacSample = HKQuantitySample(type: bacType, quantity: bacQuantity, start: date, end: date)
        
        HKHealthStore().save(bacSample) { (success, error) in
              if let error = error {
                print("Error Saving weight Sample: \(error.localizedDescription)")
                completion(false, nil)
              } else {
                print("done")
                completion(true, nil)
              }
        }
    }
    
    class func getWeight(completion: @escaping (HKQuantitySample?, Error?) -> Void){
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {fatalError("Data type bodymass is not part of HealthKit")}
        
        getMostRecentSample(for: sampleType, completion: completion)
    }
    
    class func getHeight(completion: @escaping (HKQuantitySample?, Error?) -> Void){
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .height) else {fatalError("Data type height is not part of HealthKit")}
        
        getMostRecentSample(for: sampleType, completion: completion)
    }
    
    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
      let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                            end: Date(),
                                                            options: .strictEndDate)
      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                            ascending: false)
      let limit = 1
      let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                      predicate: mostRecentPredicate,
                                      limit: limit,
                                      sortDescriptors: [sortDescriptor]) { (query, samples, error) in
        //2. Always dispatch to the main thread when complete.
        DispatchQueue.main.async {
          guard
            let samples = samples,
            let mostRecentSample = samples.first as? HKQuantitySample
            else {
              completion(nil, error)
              return
          }
          completion(mostRecentSample, nil)
        }
      }
      HKHealthStore().execute(sampleQuery)
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitn not avaible at this device")
            completion(false, nil)
            return
        }
        guard let height = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height),
              let weight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass),
              let age = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth),
              let sex = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex),
              let bac = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodAlcoholContent)
        else {fatalError("HK type not avaibile")}
        
        let HKitTypesToRead : Set<HKObjectType> = [height, weight, age, sex, bac]
        let HKitTypesToWrite : Set<HKSampleType> = [bac]
        
        HKHealthStore().requestAuthorization(toShare: HKitTypesToWrite, read: HKitTypesToRead) {
            (success, error) in
            completion(success, error)
        }
    }
}

