//
//  AlcoholModel.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 13.03.2021.
//

import Foundation

typealias Concentration = Double

class AlcoholModel {
    let beta = 0.15 // g/l/h empty stomach (6.5 hours−1) or a full stomach (2.3 hours−1).
    
    struct PersonalData{
        let sex: Gender
        let height: Measurement<UnitLength>  //meters
        let weight: Measurement<UnitMass>  //kilograms
        let age: Double    //years
    }
    enum Gender {
        case male
        case female
    }
    
    enum RFactorMethod {
        case seidel
        case forrest
        case ulrich
        case watson
        case watsonB
    }
    
    func run(personalData: PersonalData, from: Date, to: Date, complition: (_ graphEntry: [Concentration]?, _ succes: Bool)->Void ){
        
        guard let recordsData = CoreDataManager.fetchRecordsBetween(from: from, to: to) as? [DrinkRecord]
        else {myDebugPrint("could not retrive data from database", "AlcoholModel"); complition(nil, false); return}
        
        let zeroTimePoint = Calendar.current.date(bySetting: .second, value: 0, of: from) // rounding down time to be percize for a minutes
        
        var allDrinksCalculatedInSec : [TimeInterval:Concentration] = [:]
        for record in recordsData {
            let currentRecTimePoint = Calendar.current.date(bySetting: .second, value: 0, of: record.timestemp!) // rounding down time to be accurate of a minute
            let difference = Calendar.current.dateComponents([.second], from: zeroTimePoint!, to: currentRecTimePoint!)
            guard let secInterval = difference.second else {continue}

            
            let curve = calculateAborbtionCurve(drink: record, method: .forrest, person: personalData, zeroPointShift: TimeInterval(secInterval))
            
            
            for (key, value) in curve{
                let tmp = allDrinksCalculatedInSec[key] ?? 0
                allDrinksCalculatedInSec[key] = tmp+value
            }
        }
        let timeBetweenFromTo = Calendar.current.dateComponents([.minute], from: from, to: to)
        guard let minInterval = timeBetweenFromTo.minute else {return}
        for i in stride(from: 0, to: minInterval, by: 1) {
            let tmp = allDrinksCalculatedInSec[TimeInterval(i * 60)] ?? 0
            allDrinksCalculatedInSec[TimeInterval(i * 60)] = tmp
        }
        
        var allDrinksCalculatedInMinArr : [Concentration] = []
        for key in Array(allDrinksCalculatedInSec.keys.sorted(by: <)) {
            allDrinksCalculatedInMinArr.append(allDrinksCalculatedInSec[key] ?? 0)
        }
        
        
        complition(allDrinksCalculatedInMinArr, true)
        return
    }
    
    private func calculateAborbtionCurve(drink : DrinkRecord, method: RFactorMethod, person: PersonalData, zeroPointShift: TimeInterval) -> [TimeInterval:Concentration] {
        let dose : Double = drink.grams_of_alcohol
        let r : Double = rFactorFor(method: .forrest, person: person)
        let v_d : Double = r * person.weight.value
        let k_a : Double = 18 // shoud varie on gender

        var c : Concentration = 0
        var time : TimeInterval = 0
        var results : [TimeInterval:Concentration] = [:]
        repeat {
            results[time+zeroPointShift] = c
            time += 60
            let t = time / 3600
            c = ((dose * (1 - exp(-k_a * t) ) ) / v_d) - beta * t
        } while (c > 0)
        
        //myPrint(results, title: "\(drink.grams_of_alcohol)")
        return results
    }
    
    private func rFactorFor(method: RFactorMethod, person: PersonalData) -> Double{
        switch method {
        case .forrest:
            return rForrest(person)
        case .seidel:
            return rSedel(person)
        case .ulrich:
            return rUlrich( person)
        case .watson:
            return rWatson(person)
        case .watsonB:
            return rWatsonB(person)
        default:
            return 0.0
        }
    }
    
    private func rSedel(_ person: PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        
        if person.sex == .male {
            return 0.31608 - 0.004821 * _weight + 0.4632 * _height
        } else {
            return 0.31223 - 0.006446 * _weight + 0.4466 * _height
        }
    }
    
    private func rForrest(_ person: PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        
        if person.sex == .male {
            return 1.0178 - (0.012127 * _weight) / (_height * _height)
        } else {
            return 0.8736 - (0.0124 * _weight) / (_height * _height)
        }
    }
    
    private func rUlrich(_ person: PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        
        if person.sex == .male {
            return 0.715 - 0.00462 * _weight + 0.22 * _height
        }else {
            fatalError("Ulrich doesnt have formula for females")
        }
    }
    
    private func rWatson(_ person: PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        let _age = person.age
        
        if person.sex == .male {
            return 0.39834 + (12.725 * _height) / _weight - (0.11275 * _age) / _weight + 2.8993 / _weight
        }else {
            return 0.29218 + (12.666 * _height) / _weight - 2.4846 / _weight
        }
    }
    
    private func rWatsonB(_ person: PersonalData) -> Double {
        //let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        let _age = person.age
        
        if person.sex == .male {
            return (0.3626 * _weight-0.1183*_age+20.03) / (0.8*_weight)
        } else {
            return (0.2549 * _weight + 14.46) / ( 0.8 * _weight)
        }
    }
}
