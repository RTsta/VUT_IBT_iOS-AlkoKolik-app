//
//  CalendarVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.03.2021.
//

import UIKit
import FSCalendar

class CalendarVC: UIViewController {
    
    
    @IBOutlet weak var calendar: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupCalendarUI(){
    }
}

extension CalendarVC : FSCalendarDelegate, FSCalendarDataSource {
    
    /*
    func calendar(_ calendar: FSCalendar!, imageFor date: NSDate!) -> UIImage! {
    }*/
    
    // FSCalendarDelegate
    func calendar(calendar: FSCalendar!, didSelectDate date: NSDate!) {
        
    }
    
}
