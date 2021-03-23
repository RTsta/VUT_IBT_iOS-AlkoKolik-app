//
//  VolumeRowController.swift
//  AlkoKolik WatchKit Extension
//
//  Created by Arthur Nácar on 22.03.2021.
//

import WatchKit

class VolumeRowController: NSObject {
    @IBOutlet var volumeLabel: WKInterfaceLabel!
    
    var volume: Double? {
      didSet {
        guard let volume = volume else { return }
        volumeLabel.setText("\(volume) ml")
      }
    }
}
