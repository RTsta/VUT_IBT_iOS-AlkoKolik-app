//
//  HealthKitManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 20.02.2021.
//

import Foundation
import HealthKit

class HealthKitManager{
    
    class func insertBAC(bac: Double ,forDate: Date,completion: @escaping (Bool, Error?) -> Void = {_,_ in }){
        guard let bacType = HKQuantityType.quantityType(forIdentifier: .bloodAlcoholContent) else {
            fatalError("HealthKitManager - Error - Data type BAC is no longer part of healthkit")
        }
        let bacQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .none), doubleValue: bac)
        
        let date = forDate
        
        let bacSample = HKQuantitySample(type: bacType, quantity: bacQuantity, start: date, end: date)
        
        HKHealthStore().save(bacSample) { (success, error) in
            if let error = error {
                print("HealthKitManager - Error - Error Saving weight Sample: \(error.localizedDescription)")
                completion(false, nil)
            } else {
                print("HealthKitManager - Error - BAC inserted")
                completion(true, nil)
            }
        }
    }
    
    class func getPersonalData(completion: @escaping (_ l: Measurement<UnitLength>?,_ w: Measurement<UnitMass>?,_ a: Double?,_ s: AlcoholModel.Gender?) -> Void){
        let dispatchGroup = DispatchGroup()
        var height : Measurement<UnitLength>?
        var weight : Measurement<UnitMass>?
        var sex : AlcoholModel.Gender?
        var age : Double?
        
        do {
            let _sex = try HKHealthStore().biologicalSex().biologicalSex
            if _sex == .male {sex = .male} else if _sex == .female {sex = .female}
            
            let dateOfBirth = try HKHealthStore().dateOfBirthComponents()
            let todayDateComponents = Calendar.current.dateComponents([.year],from: Date())
            let thisYear = todayDateComponents.year!
            age = Double(thisYear - dateOfBirth.year!)
        } catch let _error { print("HealthKitManager - Error - error in healthkit - \(_error.localizedDescription)")}
        
        guard let heightType = HKQuantityType.quantityType(forIdentifier: .height),
              let massType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else {fatalError("Data type height is not part of HealthKit")}
        
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let heightSampleQuery = HKSampleQuery(sampleType: heightType,
                                              predicate: mostRecentPredicate,
                                              limit: 1,
                                              sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else { return }
                let _h = mostRecentSample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
                height = Measurement(value: _h, unit: UnitLength.centimeters)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.enter()
        HKHealthStore().execute(heightSampleQuery)
        let massSampleQuery = HKSampleQuery(sampleType: massType,
                                            predicate: mostRecentPredicate,
                                            limit: 1,
                                            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else { return }
                let _w = mostRecentSample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                weight = Measurement(value: _w, unit: UnitMass.kilograms)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.enter()
        HKHealthStore().execute(massSampleQuery)
        
        dispatchGroup.notify(queue: .main){
            completion(height,weight,age,sex)
        }
        
    }
    
    class func getHeight(completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void)  -> Void {
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .height) else {fatalError("Data type height is not part of HealthKit")}
        
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: 1,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            //2. Always dispatch to the main thread when complete.
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    completion(nil, error)
                    return
                }
                
                completion(mostRecentSample, nil)
            }
        }
        HKHealthStore().execute(sampleQuery)
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
            print("HealthKitManager - Error - HealthKit is not avaible at this device")
            completion(false, nil)
            return
        }
        guard let height = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height),
              let weight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass),
              let age = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.dateOfBirth),
              let sex = HKObjectType.characteristicType(forIdentifier: HKCharacteristicTypeIdentifier.biologicalSex),
              let bac = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bloodAlcoholContent)
        else {fatalError("HealthKitManager - Error - HK type not avaibile")}
        
        let HKitTypesToRead : Set<HKObjectType> = [height, weight, age, sex, bac]
        let HKitTypesToWrite : Set<HKSampleType> = [bac]
        
        HKHealthStore().requestAuthorization(toShare: HKitTypesToWrite, read: HKitTypesToRead) {
            (success, error) in
            completion(success, error)
        }
    }
    
    enum AccesType{
        case read
        case write
    }

    enum HKitType{
        case height
        case weight
        case age
        case sex
        case bac
    }
}

