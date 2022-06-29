//
//  AddDrinkVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit

class AddDrinkVC: UIViewController, DrinkListVCDelegate {
    
    var selectedDrink : DrinkItem?
    var selectedVolume : Int?
    var selectedDate : Date = Date()
    let datePicker = UIDatePicker()
    let volumePickerView = UIPickerView() //TODO: předělat na lazy var
    var model : AppModel?
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var volumeText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard let _drink = selectedDrink,
              let _volume = selectedVolume else {fatalError("something is not selected ")}
        CoreDataManager.insertRecord(drink: _drink, volumeOpt: _volume, time: selectedDate)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func createDatePicker(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneDatePickerPressed))
        doneBtn.tintColor = UIColor(named: "appButoon")
        let btnSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([btnSpace, doneBtn], animated: true)

        
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
        let btnSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([btnSpace,doneBtn], animated: true)
        
        volumeText.inputAccessoryView = toolBar
        volumeText.inputView = volumePickerView
    }
    
    @objc func doneVolumePickerPressed(){
        if let _drink = selectedDrink,
           let _selVolume = selectedVolume {
            volumeText.text = "\(_drink.volume[_selVolume]) ml"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DrinkListContainerVC,
           let _model = model{
            vc.delegate = self
            vc.model = _model
            vc.isTableSelectable = true
        }
    }
    
    func didSelectedDrink(_ drink: DrinkItem?) {
        if let _drink = drink{
            selectedDrink = drink
            selectedVolume = 0
            volumeText.text = "\(_drink.volume[selectedVolume!]) ml"
            saveBtn.isEnabled = true
            volumePickerView.selectRow(0, inComponent: 0, animated: true)
            volumePickerView.reloadAllComponents();
        }
    }
    
    func didDeselectDrink() {
        volumeText.text = NSLocalizedString("select_drink", comment: "Select dring in table at AddDrinkVC")
        selectedDrink = nil
        selectedVolume = nil
        saveBtn.isEnabled = false
    }
}


// MARK: PickerView
extension AddDrinkVC : UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let _drink = selectedDrink else {return 0}
        return _drink.volume.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let _drink = selectedDrink else {return ""}
        return "\(_drink.volume[row]) ml"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedVolume = row
        
        if let _drink = selectedDrink,
           let _selVolume = selectedVolume {
            volumeText.text = "\(_drink.volume[_selVolume]) ml"
        }
    }
}
