//
//  HealthKitManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 20.02.2021.
//

import Foundation
import HealthKit

class HealthKitManager{
    
    func insertBAC(weight: Double ,completion: @escaping (Bool, Error?) -> Void = {_,_ in }){
          
        guard let bacType = HKQuantityType.quantityType(forIdentifier: .bloodAlcoholContent) else {
            fatalError("Data type BAC is no longer part of healthkit")
        }
            
        //2.  Create a body mass quantity
        let bacQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .none), doubleValue: weight)
        
        let date = Date()
            
        let bacSample = HKQuantitySample(type: bacType, quantity: bacQuantity, start: date, end: date)
        
        //3.  Save the same to HealthKit
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
    
    func getWeight(from: Date, to: Date, completion: @escaping ([HKQuantitySample]?, Error?) -> Void){
        //1. Use HKQuery to load the most recent samples.
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {fatalError("datový typ bodyMass není součástí HealthKitu")}
        
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: from, end: to, options: .strictEndDate)
            
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            
        let limit = 1
            
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 100, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample] else {
                    completion(nil, error)
                    return
                }
                
                completion(samples, nil)
            }
        }
        HKHealthStore().execute(sampleQuery)
    }
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitn not avaible at this device")
            completion(false, nil)
            return
        }
        
        let HKitTypesToRead : Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]
        
        let HKitTypesToWrite : Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!]

        
        HKHealthStore().requestAuthorization(toShare: HKitTypesToWrite, read: HKitTypesToRead) {
            (success, error) in
            completion(success, error)
        }
    }
}

