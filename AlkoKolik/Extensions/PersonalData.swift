//
//  PersonalData.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 28.01.2022.
//

import Foundation

struct PersonalData{
    enum Gender {
        case male
        case female
    }
    
    let sex: Gender
    let height: Measurement<UnitLength>  //meters
    let weight: Measurement<UnitMass>  //kilograms
    let age: Double    //years
}
