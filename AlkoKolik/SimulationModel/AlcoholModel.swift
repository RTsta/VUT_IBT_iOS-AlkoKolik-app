//
//  AlcoholModel.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 13.03.2021.
//

import Foundation

typealias Concentration = Double

class AlcoholModel {
    let beta = 0.15 // g of eth/ l of body weight/h empty stomach (6.5 hours−1) or a full stomach (2.3 hours−1).
    
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
        case average
    }
    
    func run(personalData: PersonalData, from: Date, to: Date,method: RFactorMethod = .average ,complition: (_ graphEntry: [Concentration]?, _ succes: Bool)->Void ){
        guard let recordsData = CoreDataManager.fetchRecordsBetween(from: from, to: to) as? [DrinkRecord]
        else {myDebugPrint("could not retrive data from database", "AlcoholModel"); complition(nil, false); return}
        let zeroTimePoint = Calendar.current.date(bySetting: .second, value: 0, of: from) // rounding down time to be percize for a minutes
        let intervalBetweenStartEnd = Calendar.current.dateComponents([.minute], from: from, to: to)
        guard let _ = intervalBetweenStartEnd.minute else {complition(nil, false); return}
        var resultArray = [Concentration](repeating: 0.0, count: intervalBetweenStartEnd.minute!)
        
        for record in recordsData {
            let currentRecTimePoint = Calendar.current.date(bySetting: .second, value: 0, of: record.timestemp!) // rounding down time to be accurate of a minute
            let difference = Calendar.current.dateComponents([.minute], from: zeroTimePoint!, to: currentRecTimePoint!)
            guard let minInterval = difference.minute else {continue}
            
            let absorbtion = calculateAbsorbtionPhases(drink: record)
            for i in stride(from: 0, to: absorbtion.count, by: 1){
                if minInterval+i >= resultArray.count { break }
                resultArray[minInterval+i] += absorbtion[i]
            }
        }
        
        for i in stride(from: 1, to: resultArray.count, by: 1){
            if (resultArray[i]+resultArray[i-1]) <= 0 {continue}
            
            resultArray[i] = calculateEliminationPhases(doseInBody: resultArray[i-1], newAbsorbed: resultArray[i], person: personalData, method: method)
        }
        
        complition(resultArray, true)
        return
    }
    
    func calculateAbsorbtionPhases(drink : DrinkRecord) -> [Concentration]{
        
        let dose : Double = drink.grams_of_alcohol
        let k_a : Double = 18 // shoud varie on gender
        var time : Double = 0.0
        
        var results : [Concentration] = []
        var c_old : Concentration = 0
        var c_new : Concentration = 0
        repeat {
            results.append(c_new-c_old)
            c_old = c_new
            time += 1
            let t = time / 60
            c_new = dose * (1 - exp(-k_a * t))
        } while ((c_new/dose) < 1)
        return results
    }
    
    func calculateEliminationPhases(doseInBody: Concentration,newAbsorbed: Concentration , person: PersonalData, method: RFactorMethod) -> Concentration{
        let r : Double = rFactorFor(method: method, person: person)
        let v_d : Double = r * person.weight.converted(to: .kilograms).value
        let timeChange : Double = 1/60
        
        let dose = doseInBody * v_d + newAbsorbed

        return (dose / v_d) - beta*timeChange
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
        case .average:
            if person.sex == .male {return (rForrest(person)+rSedel(person)+rUlrich(person)+rWatson(person))/4}
            else {return (rForrest(person)+rSedel(person)+rWatson(person))/3}
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
