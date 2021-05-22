//
//  AddDrinkVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit

class AddDrinkVC: UIViewController {
    
    var listOfDrinks = [DrinkItem]()
    var selectedRow :Int?
    var selectedVolume : Int?
    var selectedDate : Date = Date()
    let datePicker = UIDatePicker()
    let volumePickerView = UIPickerView()
    var model : AppModel? = nil //TODO: Implement
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var volumeText: UITextField!
    @IBOutlet weak var drinksTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _m = model {
            listOfDrinks = _m.listOfDrinks
            listOfDrinks.sort(by: {$0.name < $1.name})
            listOfDrinks.sort(by: {$0.type < $1.type})
            drinksTable.reloadData()
        }
        timeText.tintColor = .clear
        volumeText.tintColor = .clear
        saveBtn.isEnabled = false
        
        let formater = DateFormatter()
        formater.timeStyle = .short
        timeText.text = formater.string(from: selectedDate)
        volumeText.text = NSLocalizedString("select_drink", comment: "Select dring in table at AddDrinkVC")
        createDatePicker()
        createVolumePicker()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        guard let _row = selectedRow,
              let _volume = selectedVolume else {fatalError("something is not selected ")}
        CoreDataManager.insertRecord(drink: listOfDrinks[_row], volumeOpt: _volume, time: selectedDate)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func createDatePicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneDatePickerPressed))
        doneBtn.tintColor = UIColor(named: "appButoon")
        toolBar.setItems([doneBtn], animated: true)
        
        timeText.inputAccessoryView = toolBar
        datePicker.preferredDatePickerStyle = .wheels
        timeText.inputView = datePicker
        datePicker.datePickerMode = .time
        
        datePicker.addTarget(self, action: #selector(datePickerChangedValue), for: .valueChanged)
    }
    
    @objc func doneDatePickerPressed(){
        let formater = DateFormatter()
        formater.timeStyle = .short
        timeText.text = (formater.string(from: datePicker.date))
        let selectionComponents = Calendar.current.dateComponents([.hour,.minute], from: datePicker.date)
        selectedDate = Calendar.current.date(bySettingHour: selectionComponents.hour!, minute: selectionComponents.minute!, second: 0, of: selectedDate)!
        self.view.endEditing(true)
    }
    
    func createVolumePicker(){
        volumePickerView.dataSource = self
        volumePickerView.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneVolumePickerPressed))
        doneBtn.tintColor = UIColor(named: "appButoon")
        toolBar.setItems([doneBtn], animated: true)
        
        volumeText.inputAccessoryView = toolBar
        volumeText.inputView = volumePickerView
    }
    
    @objc func doneVolumePickerPressed(){
        if let _row = selectedRow,
           let _selVolume = selectedVolume {
            volumeText.text = "\(listOfDrinks[_row].volume[_selVolume]) ml"
        }
        self.view.endEditing(true)
    }
    
    @objc func datePickerChangedValue(){
        let formater = DateFormatter()
        formater.timeStyle = .short
        timeText.text = (formater.string(from: datePicker.date))
        let selectionComponents = Calendar.current.dateComponents([.hour,.minute], from: datePicker.date)
        selectedDate = Calendar.current.date(bySettingHour: selectionComponents.hour!, minute: selectionComponents.minute!, second: 0, of: selectedDate)!
    }
}

// MARK: UITableView
extension AddDrinkVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfDrinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddDrinkListCell", for: indexPath) as? DrinkListCell else { fatalError("Cell is not an instance of DrinkListCell.") }
        
        let oneDrink = listOfDrinks[indexPath.row]
        cell.type = oneDrink.type
        cell.labelText.text = oneDrink.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectedVolume = 0
        volumeText.text = "\(listOfDrinks[selectedRow!].volume[selectedVolume!]) ml"
        saveBtn.isEnabled = true
        volumePickerView.selectRow(0, inComponent: 0, animated: true)
        volumePickerView.reloadAllComponents();
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        volumeText.text = NSLocalizedString("select_drink", comment: "Select dring in table at AddDrinkVC")
        selectedRow = nil
        selectedVolume = nil
        saveBtn.isEnabled = false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}


// MARK: PickerView
extension AddDrinkVC : UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let _row = selectedRow else {return 0}
        return listOfDrinks[_row].volume.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let _row = selectedRow else {return ""}
        return "\(listOfDrinks[_row].volume[row]) ml"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedVolume = row
        
        if let _row = selectedRow,
           let _selVolume = selectedVolume {
            volumeText.text = "\(listOfDrinks[_row].volume[_selVolume]) ml"
        }
    }
}
