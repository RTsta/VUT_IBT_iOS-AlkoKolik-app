//
//  TestDekegatingVCViewController.swift
//  
//
//  Created by Arthur Nácar on 19.06.2021.
//

import UIKit

class TestVC: UIViewController, DrinkListVCDelegate  {
    func didDeselectDrink() {
        return
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        myDebugPrint("Loaded", "TestingDelegateVC")

    }
    
    func didSelectedDrink(_ drink: DrinkItem?) {
        if let d = drink {
            myDebugPrint(d.name)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DrinkListContainerVC {
            dest.delegate = self
        }
    }
}
