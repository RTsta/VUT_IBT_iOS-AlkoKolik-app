//
//  CalendarVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.03.2021.
//

import UIKit
import CoreData
import FSCalendar

class CalendarVC: UIViewController {
    @IBOutlet weak var calendar: FSCalendar!
    
    private let today = Date()
    var selectedDate : Date = Date()
    var records : [DrinkRecord] = []
    lazy var model1 : AppModel = { return (tabBarController as? MainTabBarController)?.model ?? createNewAppModel()}()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav_vc = segue.destination as? UINavigationController,
           let vc = nav_vc.viewControllers.first as? DayVC{
            vc.selectedDate = selectedDate
            vc.callback = {self.reloadData()}
            vc.model = model1
        }
    }
    
    func createNewAppModel() -> AppModel{
        let new = AppModel()
        if let parrent = tabBarController as? MainTabBarController{
                parrent.model = new
            }
        return new
    }
    
    func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        
        calendar.scrollDirection = .vertical
        calendar.scope = .month
        calendar.firstWeekday = 2
        
        calendar.allowsMultipleSelection = false
        calendar.allowsSelection = true
        calendar.appearance.borderDefaultColor = .clear
        
    }
    
    func reloadData(){
        records = CoreDataManager.fetchRecordsAll()
        calendar.reloadData()
    }
    
}


// MARK: FSCalendar
extension CalendarVC : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date as Date
        calendar.deselect(date)
        performSegue(withIdentifier: "dayVCSegue", sender: nil)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            if date > today {
                return false
            }
            return true
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if (date as Date) > today {
            return UIColor.appDarkGrey
        }
        var sum : Double = 0
        for r in records {
            guard let timestemp = r.timestemp as Date?,
                  let dose = r.grams_of_alcohol as Double? else { break }
            if Calendar.current.isDate(timestemp, inSameDayAs: date){
                sum += dose
            }
        }
        return UIColor.colorFor(daydose: sum, gender: model1.getSex() ?? .female) //female is default, becasue it has lower balues
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return UIColor.appMax
        }
        return nil
    }
}
