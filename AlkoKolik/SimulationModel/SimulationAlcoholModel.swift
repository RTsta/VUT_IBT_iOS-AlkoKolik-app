//
//  AlcoholModel.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 13.03.2021.
//

import Foundation

typealias Concentration = Double

class SimulationAlcoholModel {
    let beta = 0.15 // g of eth/ l of body weight/h empty stomach (6.5 hours−1) or a full stomach (2.3 hours−1).
    
    enum RFactorMethod{
        case seidel
        case forrest
        case ulrich
        case watson
        case watsonB
        case average
        case all
    }
    
    func run(personalData: AppModel.PersonalData, from: Date, to: Date,method: RFactorMethod = .average ,complition: (_ graphEntry: [Concentration]?, _ succes: Bool)->Void ){
        let recordsData = CoreDataManager.fetchRecordsBetween(from: from, to: to)
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
    
    func runWithMultipleMethods(personalData: AppModel.PersonalData, from: Date, to: Date,method: [RFactorMethod] = [.all] ,complition: (_ graphEntry: [RFactorMethod:[Concentration]]?, _ succes: Bool)->Void ){
        let rFactorMethods = (method == [.all] ? [.average,.seidel ,.forrest, .ulrich, .watson] : method)
        
        let recordsData = CoreDataManager.fetchRecordsBetween(from: from, to: to)
        
        let zeroTimePoint = Calendar.current.date(bySetting: .second, value: 0, of: from) // rounding down time to be percize for a minutes
        let intervalBetweenStartEnd = Calendar.current.dateComponents([.minute], from: from, to: to)
        guard let _ = intervalBetweenStartEnd.minute else {complition(nil, false); return}
        
        var resultArray : [RFactorMethod:[Concentration]] = [:]
        
        for singleMethod in rFactorMethods {
            var resultOfSingleMethod = [Concentration](repeating: 0.0, count: intervalBetweenStartEnd.minute!)
        
            for record in recordsData {
                let currentRecordTimePoint = Calendar.current.date(bySetting: .second, value: 0, of: record.timestemp!) // rounding down time to be accurate of a minute
                let difference = Calendar.current.dateComponents([.minute], from: zeroTimePoint!, to: currentRecordTimePoint!)
                guard let minInterval = difference.minute else {continue}
            
                let absorbtion = calculateAbsorbtionPhases(drink: record)
                for i in stride(from: 0, to: absorbtion.count, by: 1){
                    if minInterval+i >= resultOfSingleMethod.count { break }
                    resultOfSingleMethod[minInterval+i] += absorbtion[i]
                }
            }
        
            for i in stride(from: 1, to: resultOfSingleMethod.count, by: 1){
                if (resultOfSingleMethod[i]+resultOfSingleMethod[i-1]) <= 0 {continue}
            
                resultOfSingleMethod[i] = calculateEliminationPhases(doseInBody: resultOfSingleMethod[i-1], newAbsorbed: resultOfSingleMethod[i], person: personalData, method: singleMethod)
            }
            resultArray[singleMethod] = resultOfSingleMethod
        }
        complition(resultArray, true)
        return
    }
    
    func calculateAbsorbtionPhases(drink : DrinkRecord) -> [Concentration]{
        
        let dose : Double = drink.grams_of_alcohol
        let k_a : Double = 16
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
    
    func calculateEliminationPhases(doseInBody: Concentration,newAbsorbed: Concentration , person: AppModel.PersonalData, method: RFactorMethod) -> Concentration{
        let r : Double = rFactorFor(method: method, person: person)
        let v_d : Double = r * person.weight.converted(to: .kilograms).value
        let timeChange : Double = 1/60
        
        let dose = doseInBody * v_d + newAbsorbed
        let c = (dose / v_d) - beta*timeChange
        return c > 0 ? c : 0
    }
    
    private func rFactorFor(method: RFactorMethod, person: AppModel.PersonalData) -> Double{
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
            return 0
        }
        
    }
    
    private func rSedel(_ person: AppModel.PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        
        if person.sex == .male {
            return 0.31608 - 0.004821 * _weight + 0.4632 * _height
        } else {
            return 0.31223 - 0.006446 * _weight + 0.4466 * _height
        }
    }
    
    private func rForrest(_ person: AppModel.PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        
        if person.sex == .male {
            return 1.0178 - (0.012127 * _weight) / (_height * _height)
        } else {
            return 0.8736 - (0.0124 * _weight) / (_height * _height)
        }
    }
    
    private func rUlrich(_ person: AppModel.PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        
        if person.sex == .male {
            return 0.715 - 0.00462 * _weight + 0.22 * _height
        }else {
            //fatalError("Ulrich doesnt have formula for females")
            return 0
        }
    }
    
    private func rWatson(_ person: AppModel.PersonalData) -> Double {
        let _height = person.height.converted(to: .meters).value
        let _weight = person.weight.converted(to: .kilograms).value
        let _age = person.age
        
        if person.sex == .male {
            return 0.39834 + (12.725 * _height) / _weight - (0.11275 * _age) / _weight + 2.8993 / _weight
        }else {
            return 0.29218 + (12.666 * _height) / _weight - 2.4846 / _weight
        }
    }
    
    private func rWatsonB(_ person: AppModel.PersonalData) -> Double {
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
