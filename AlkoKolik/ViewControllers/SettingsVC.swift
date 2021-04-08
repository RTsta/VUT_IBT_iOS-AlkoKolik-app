//
//  SettingsVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.03.2021.
//

import Foundation
import UIKit

class SettingsVC: UITableViewController  {
    
    @IBAction func clearButton(_ sender: Any) {
        UserDefaultsManager.saveFavourite(drinks: [])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
