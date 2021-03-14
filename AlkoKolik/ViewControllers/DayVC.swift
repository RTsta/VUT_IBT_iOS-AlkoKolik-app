//
//  DayVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 11.03.2021.
//

import UIKit
import CoreData
import FSCalendar

class DayVC : UIViewController {
    
    private let today = Date()
    
    var selectedDate : Date = Date()
    var weekRecords : [NSManagedObject] = []
    var selectedDayRecords : [NSManagedObject] = []
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var todayDrinkTable: UITableView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        weekRecords = CoreDataManager.fetchRecordsForWeekPastAndNext(dayOfTheWeek: selectedDate)
        selectedDayRecords = recoredsFor(day: selectedDate)
        selectedDayRecords.reverse()
        updateTableContentInset()
        todayDrinkTable.reloadData()
        calendar.reloadData()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddDrinkVC {
            let now = Date()
            let hour = Calendar.current.component(.hour, from: now)
            let min = Calendar.current.component(.minute, from: now)
           
            let selectedDayWithNowTime = Calendar.current.date(bySettingHour: hour, minute: min, second: 0, of: selectedDate) ?? selectedDate
            vc.selectedDate = selectedDayWithNowTime
        }
    }
    
    func recoredsFor(day : Date) -> [NSManagedObject] {
        var rec : [NSManagedObject] = []
        for case let r as DrinkRecord in weekRecords {
            if let ts = r.timestemp as Date?,
                Calendar.current.isDate(ts, inSameDayAs: day){
                rec.append(r)
            }
        }
        return rec
    }
}

// MARK: FSCalendar
extension DayVC : FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func setupCalendar(){
        calendar.scrollDirection = .horizontal
        calendar.scope = .week
        calendar.firstWeekday = 2
        calendar.sizeToFit()
        calendar.select(selectedDate)
        self.view.layoutIfNeeded()
        
        calendar.allowsMultipleSelection = false
        calendar.allowsSelection = true
        calendar.appearance.borderDefaultColor = .clear
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if Calendar.current.isDate(date, equalTo: selectedDate, toGranularity: .weekOfYear) {
            weekRecords = CoreDataManager.fetchRecordsForWeekPastAndNext(dayOfTheWeek: selectedDate)
            calendar.reloadData()
        }
        selectedDate = date
        selectedDayRecords = recoredsFor(day: date)
        selectedDayRecords.reverse()
        
        todayDrinkTable.reloadData()
        updateTableContentInset()
        todayDrinkTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            if (date as Date) > today {
                return false
            }
            return true
    }
    
    // MARK: Appearance
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if (date as Date) > today {
            return UIColor.appDarkGrey
        }
        var sum : Double = 0
        for case let r as DrinkRecord in weekRecords {
            guard let timestemp = r.timestemp as Date?,
                  let dose = r.grams_of_alcohol as Double? else { break }
            if Calendar.current.isDate(timestemp, inSameDayAs: date){
                sum += dose
            }
        }
        return UIColor.colorFor(daydose: sum)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        if Calendar.current.isDateInToday(date) {
            return UIColor.appMax
        }
        return nil
    }
    
}


// MARK: UITableView
extension DayVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDayRecords.count + 1
    }
    //todayDrinkAddTableCell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //last/first cell is add plus button
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "todayDrinkAddTableCell", for: indexPath) as? TodayDrinkAddTableCell
            else { fatalError("Cell is not an instance of TodayDrinkTable.") }
            cell.backgroundColor = .appBackground
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "todayDrinkTableCell", for: indexPath) as? TodayDrinkTableCell
        else { fatalError("Cell is not an instance of TodayDrinkTable.") }
        
        if selectedDayRecords.count > 0,
           let idOfDrink = selectedDayRecords[indexPath.row-1].value(forKey: "drink_id") as? Int,
           let cellForDrink = ListOfDrinksManager.findDrink(drink_id: idOfDrink) {
            cell.style = .drink
            cell.backgroundColor = UIColor.colorFor(drinkType: cellForDrink.type)
            cell.drinkLabel.text = "\(cellForDrink.name)"
        }
        return cell
    }
    
    func updateTableContentInset() {
        let numRows = self.todayDrinkTable.numberOfRows(inSection: 0)
        var contentInsetTop = self.todayDrinkTable.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.todayDrinkTable.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 0 {
                contentInsetTop = 0
                break
            }
        }
        self.todayDrinkTable.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "addDrinkToSelectedDaySegue", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            CoreDataManager.deleteRecord(record: weekRecords[indexPath.row])
            weekRecords.remove(at: indexPath.row)
            selectedDayRecords.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            calendar.reloadData()
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 {
            return .none
        }else {
            return .delete
        }
    }
    
}
