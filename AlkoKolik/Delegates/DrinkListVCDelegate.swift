//
//  DrinkListVCDelegate.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 19.06.2021.
//

import UIKit

protocol DrinkListVCDelegate: AnyObject { //TUTORIAL
    func didSelectedDrink(_ drink: DrinkItem?)
    func didDeselectDrink()
}
