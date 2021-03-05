//
//  ViewController.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 08.02.2021.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var clock: UIClockView!
    @IBOutlet weak var favouriteBtnsView: FavouriteButtonsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        clock.startClock()
    }

}

