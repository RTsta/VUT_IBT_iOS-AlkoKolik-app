//
//  AlcoholModel.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 13.03.2021.
//

import Foundation

class AlcoholModel {
    
    let beta = 0.15 // g/l/h
    
    lazy var weightKg: () = HealthKitManager.getWeight(completion: {_,_ in })
    lazy var heightCm: () = HealthKitManager.getHeight(completion:{_,_ in })
    //var heightM: {return heightCm / 100}
    
    //lazy var age: () = HealthKitManager.getAge(completion: {_,_ in }
    /*
     Q_males = 0.3362*weight_kg+10.74*height_m-0.09516*age+2.447
     Q_females = 0.2466*weight_kg-10.69*height_m-2.097
     
     def testWidmarkDelution(time_in_m):
     time_in_h = time_in_m/60
     return (v*z*a*d)/(r*weight_kg)-beta*time_in_h
     
     def testWagner(time_in_h, oldBAC):
     v_max = 0.17
     k_m = 0.045
     x = (-(v_max*oldBAC)/(k_m*oldBAC))/Q_males
     return x
     */
    private enum Gender {
        case male
        case female
    }
    
    enum RFactorMethod {
        case seidel
        case forrest
        case ulrich
        case watson
    }
    /*
     func rSedel(gender : Gender) -> Double {
     if gender == .male { return 0.31608 - 0.004821 * weightKg + 0.4632 * heightM }
     else { return 0.31223 - 0.006446 * weightKg + 0.4466 * heightM }
     }
     
     func rForrest(){
     if gender == .male { return 1.0178 - (0.012127 * weightKg) / (heightM * heightM) }
     else {return 0.8736 - (0.0124 * weightKg) / (heightM * heightM)}
     }
     
     func rUlrich(){
     if gender == .male {return 0.715 - 0.00462 * weightKg + 0.22 * heightM}
     else {fatalError("Ulrich doesnt have formula for females")}
     }
     
     func rWatson(){
     if gender == .male {return 0.39834 + (12.725 * heightM) / weightKg - (0.11275 * age) / weightKg + 2.8993 / weightKg}
     else {return 0.29218 + (12.666 * heightM) / weightKg - 2.4846 / weightKg}
     /*
     r_Watson_m_b = (0.3626*weight_kg-0.1183*age+20.03)/(0.8*weight_kg)
     r_Watson_f_b = (0.2549*weight_kg+14.46)/(0.8*weight_kg)
     */
     }
     */
    /*
     func absorbtionOfDrink(drink : DrinkRecord, atTime at: TimeInterval) -> Double {
     let dose = drink.grams_of_alcohol
     let v_d = r * weightKg
     let k_a = 18
     let time = Double(at / 3600)
     return ((dose * (1 - exp(-k_a * time) ) ) / v_d) - beta * time
     }
     */
    /*
     func runTest(timeOfsimulation time: Int) {
     let timestep : Double = 0.5
     var i : Double = 0
     var xs : [Double] = []
     var ys : [Double] = []
     while i <= time{
     xs.append(i)
     let y = absorbtionOfDrink(drink: , atTime: i)
     if y < 0{
     break
     }
     ys.append(y)
     i += timestep
     }
     }
     */
}
