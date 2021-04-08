//
//  HandyExtensions.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 04.03.2021.
//

import Foundation
import UIKit

extension FloatingPoint {
    var radians: Self {
        return self * .pi / Self(180)
    }
}

extension CGRect {
    var center : CGPoint {
        return CGPoint(x:self.midX, y:self.midY)
    }
}

extension Notification.Name {
    static let favouriteNeedsReload = Notification.Name("favouriteNeedsReload")
    static let favouriteBtnPressd = Notification.Name("favouriteBtnPressd")
    static let watchRequestedUpdate = Notification.Name("watchRequestedUpdate")
    static let modelCalculated = Notification.Name("alcoholModelAverageWasUpdated")
    static let mulitpleModelCalculated = Notification.Name("alcoholModelAllWasUpdated")
}
