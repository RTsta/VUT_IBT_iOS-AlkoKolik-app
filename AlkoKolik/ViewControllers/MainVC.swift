//
//  ViewController.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 08.02.2021.
//

import UIKit

class MainVC: UIViewController, UIClockViewDelegate {

    @IBOutlet weak var clock: UIClockView!
    @IBOutlet weak var favouriteBtnsView: FavouriteButtonsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        clock.uiClockViewDelegate = self
        clock.displayRealTime = true
        
        clock.refreshInterval = Double(1.0)
        clock.startClock()
    }

    func timeIsSetManually() {
        //o
    }
    
    func clockStopped() {
        //o
    }
    
    func countDownExpired() {
        //o
    }

}

