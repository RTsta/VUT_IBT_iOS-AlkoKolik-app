//
//  FloatingPoint.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 04.03.2021.
//

import Foundation

extension FloatingPoint {
    var radians: Self {
        return self * .pi / Self(180)
    }
}
