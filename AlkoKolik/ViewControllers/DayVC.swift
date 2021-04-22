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
    var weekRecords : [DrinkRecord] = []
    var selectedDayRecords : [DrinkRecord] = []
    var callback : (() -> Void)?
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var todayDrinkTable: UITableView!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(callendarSwipeGesture))
        swipeRightGesture.direction = .right
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(callendarSwipeGesture))
        swipeLeftGesture.direction = .left
        todayDrinkTable.addGestureRecognizer(swipeRightGesture)
        todayDrinkTable.addGestureRecognizer(swipeLeftGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        weekRecords = CoreDataManager.fetchRecordsBetween(from: Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!,
                                                          to: Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!)
        selectedDayRecords = recoredsFor(day: selectedDate)
        selectedDayRecords.reverse()
        updateTableContentInset()
        todayDrinkTable.reloadData()
        calendar.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if selectedDayRecords.count > 8 {todayDrinkTable.scrollToRow(at: IndexPath(row: 8, section: 0), at: .bottom, animated: true)
        }else {todayDrinkTable.scrollToRow(at: IndexPath(row: selectedDayRecords.count, section: 0), at: .bottom, animated: true)}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callback?()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func recoredsFor(day : Date) -> [DrinkRecord] {
        var rec : [DrinkRecord] = []
        for r in weekRecords {
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
            weekRecords = CoreDataManager.fetchRecordsBetween(from: Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!,
                                                              to: Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!)
            calendar.reloadData()
        }
        selectedDate = date
        selectedDayRecords = recoredsFor(day: date)
        selectedDayRecords.reverse()
        
        todayDrinkTable.reloadData()
        updateTableContentInset()
        if selectedDayRecords.count > 8 {todayDrinkTable.scrollToRow(at: IndexPath(row: 8, section: 0), at: .bottom, animated: true)
        }else {todayDrinkTable.scrollToRow(at: IndexPath(row: selectedDayRecords.count, section: 0), at: .bottom, animated: true)}
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
        for r in weekRecords {
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
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
}


// MARK: UITableView
extension DayVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDayRecords.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
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
           let volumeOfDrink = selectedDayRecords[indexPath.row-1].value(forKey: "volume") as? Double,
           let timestempOfDrink = selectedDayRecords[indexPath.row-1].value(forKey: "timestemp") as? Date,
           let cellForDrink = ListOfDrinksManager.findDrink(drink_id: idOfDrink) {
            let time = Calendar.current.dateComponents([.hour, .minute], from: timestempOfDrink)
            cell.style = .drink
            cell.backgroundColor = UIColor.colorFor(drinkType: cellForDrink.type)
            cell.drinkLabel.text = "\(volumeOfDrink) ml, \(cellForDrink.name)"
            if let _ = time.minute, let _ = time.hour {
                let min = time.minute! < 10 ? "0\(time.minute!)" : "\(time.minute!)"
                cell.timeLabel.text = "\(time.hour!):\(min)"
            }
            
        }
        return cell
    }
    
    func updateTableContentInset() {
        let numRows = self.todayDrinkTable.numberOfRows(inSection: 0)
        var contentInsetTop = self.todayDrinkTable.bounds.size.height
        for i in stride(from: 0, to: numRows, by: 1) {
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
            CoreDataManager.deleteRecord(record: selectedDayRecords[indexPath.row-1])
            selectedDayRecords.remove(at: indexPath.row-1)
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
    
    @objc func callendarSwipeGesture(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .right) ||  (sender.direction == .left) {
            let change = (sender.direction == .left) ? 1 : -1
            
            let newDate = Calendar.current.date(byAdding: .day, value: change, to: selectedDate) ?? selectedDate
            if newDate > Date() {return}
            calendar.select(newDate)
            if Calendar.current.isDate(newDate, equalTo: selectedDate, toGranularity: .weekOfYear) {
                weekRecords = CoreDataManager.fetchRecordsBetween(from: Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!,
                                                                  to: Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!)
                calendar.reloadData()
            }
            selectedDate = newDate
            selectedDayRecords = recoredsFor(day: newDate)
            selectedDayRecords.reverse()
            
            todayDrinkTable.reloadData()
            updateTableContentInset()
            if selectedDayRecords.count > 8 {
                todayDrinkTable.scrollToRow(at: IndexPath(row: 8, section: 0), at: .bottom, animated: true)
            }else {
                todayDrinkTable.scrollToRow(at: IndexPath(row: selectedDayRecords.count, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
}
