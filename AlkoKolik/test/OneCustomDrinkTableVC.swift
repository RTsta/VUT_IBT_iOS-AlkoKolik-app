//
//  AddCustomDrinkTableVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 30.01.2022.
//

import UIKit

// https://stackoverflow.com/questions/48440713/insert-row-tableview-with-a-button-at-last-section
// https://stackoverflow.com/questions/25058891/uitableview-insert-new-row-by-tapping-on-existing-cell
// TODO: Localize
//TODO: in section 1 předělat jednu cell, aby obsahovala label
class OneCustomDrinkTableVC: UITableViewController  {
    
    @IBOutlet weak var navBarRightBtn: UIBarButtonItem!
    
    var model : AppModel?
    var drink: DrinkItem? { didSet{
        guard let drink = drink else {return}
        customDrinkName = drink.name
        customDrinkType = drink.type
        customDrinkPercentage = drink.alcoholPercentage
        volumes = drink.volume.map({"\($0)"})
    }}
    
    
    private var customDrinkName : String = "" { didSet { checkNavBarRightBtnConditions() }}
    private var customDrinkType : DrinkType = .none { didSet { checkNavBarRightBtnConditions() }}
    private var customDrinkPercentage : Double = 0.0 { didSet { checkNavBarRightBtnConditions() }}
    private var volumes : [String] = [] { didSet { checkNavBarRightBtnConditions() }}
    
    lazy var typePickerView : UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isEditing = true
        navBarRightBtn.target = self
        navBarRightBtn.action = #selector(navBarRightBtnPressed)
        navBarRightBtn.isEnabled = false
        if let _ = drink {navBarRightBtn.title = "Update"}
        else {navBarRightBtn.title = "Insert"} //TODO: Localize
        checkNavBarRightBtnConditions()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func updateCustomDrinkName(){
        guard let nameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddCustomDrinkCell else { print("Error - AddCustromDrinkTableVC - not a instance of AddCustomDrinkCell"); return }
        customDrinkName = nameCell.textField.text ?? ""
    }
    
    @objc func updateCustomDrinkPercentage(){
        guard let percentageCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? AddCustomDrinkCell else { print("Error - AddCustromDrinkTableVC - not a instance of AddCustomDrinkCell"); return }
        customDrinkPercentage = Double(percentageCell.textField.text?.replacingOccurrences(of: ",", with: ".") ?? "0.0") ?? 0.0
    }
    
    @objc func updateCustomDrinkVolumes(){
        for rowNum in 0..<self.tableView.numberOfRows(inSection: 1)-1{
            guard let volumeCell = tableView.cellForRow(at: IndexPath(row: rowNum, section: 1)) as? AddCustomDrinkCell else { print("Error - AddCustromDrinkTableVC - not a instance of AddCustomDrinkCell"); return }
            volumes[rowNum] = volumeCell.textField.text ?? ""
        }
    }
    
    func checkNavBarRightBtnConditions(){
        //TODO: zpřehlednit
        if (customDrinkName != "") && (customDrinkPercentage > 0.0) && (customDrinkPercentage <= 100.0) && (customDrinkType != .none) && volumes.filter({ (Double($0.replacingOccurrences(of: ",", with: ".")) ?? 0.0) != 0.0 }) != [] {
                navBarRightBtn.isEnabled = true
        } else { navBarRightBtn.isEnabled = false}
    }
    
    @objc func navBarRightBtnPressed(){
        var convertedVolumes = volumes.compactMap({Double($0.replacingOccurrences(of: ",", with: "."))})
        convertedVolumes = convertedVolumes.filter({$0 != 0.0})
        //if drink not nill it means, I edit some drink, that is already in the database
        if let _drink = drink {
            CoreDataManager.updateCustomDrinks(of: _drink, name: customDrinkName, drinkType: customDrinkType, percentage: customDrinkPercentage, volumes: convertedVolumes)
            NotificationCenter.default.post(name: .favouriteNeedsReload, object: nil)
            
        }
        else {
            CoreDataManager.insertCustomDrink(name: customDrinkName,
                                          type: customDrinkType,
                                          percentage: customDrinkPercentage, volumes: convertedVolumes)
        }
        model?.updateCustomDrinks()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return volumes.count+1
        default:
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 1:
            return true
        default:
            return false
        }
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch indexPath.section {
        case 1:
            if indexPath.row < volumes.count {return UITableViewCell.EditingStyle.delete }
            else { return UITableViewCell.EditingStyle.insert}
        default:
            return UITableViewCell.EditingStyle.none
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == volumes.count && volumes.count < 7{
            tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.beginUpdates()
            volumes.append("")
            tableView.insertRows(at: [IndexPath(row: indexPath.row+1, section: indexPath.section)], with: .top)
            self.tableView.endUpdates()
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "add_custom_drink_cell") as? AddCustomDrinkCell else {fatalError("Cell is not an instance of AddCustomDrinkCell.")}
        
        switch indexPath.section {
        case 0:
            switch indexPath.row{
            case 0:
                cell.textField.placeholder = "Name"
                cell.textField.text = customDrinkName
                cell.textField.addTarget(self, action: #selector(updateCustomDrinkName), for: .editingChanged)
            case 1:
                cell.textField.placeholder = "Type"
                cell.textField.text = customDrinkType.text()
                cell.textField.inputView = typePickerView
                cell.textField.tintColor = .clear
            case 2:
                cell.textField.placeholder = "%"
                cell.textField.text = (customDrinkPercentage == 0.0 ? "" : "\(customDrinkPercentage)")
                cell.textField.keyboardType = .decimalPad
                cell.textField.addTarget(self, action: #selector(updateCustomDrinkPercentage), for: .editingChanged)
            default:
                break
            }
        case 1:
            cell.textField.keyboardType = .decimalPad
            cell.textField.placeholder = "volume"
            cell.textField.isEnabled = true
            cell.textField.addTarget(self, action: #selector(updateCustomDrinkVolumes), for: .editingChanged)
            if indexPath.row < volumes.count {
                cell.textField.text = volumes[indexPath.row]
                cell.textField.keyboardType = .decimalPad
            }else {
                cell.textField.text = "Insert volume"
                cell.textField.isEnabled = false
            }
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert{
            //case, where is not previous cell filled with any value, so it doesnt let you to create next cell
            if let previousCell = tableView.cellForRow(at: IndexPath(row: indexPath.row-1, section: indexPath.section)) as? AddCustomDrinkCell, previousCell.textField.text == "" {
                return
            }
            
            //max 7 volumes can be inserted
            if volumes.count >= 7{
                return
            }
            
            if let cell = tableView.cellForRow(at: indexPath) as? AddCustomDrinkCell{
                self.tableView.beginUpdates()
                cell.textField.isEnabled = true
                cell.textField.text = ""
                //TODO: tady to dodělat
                volumes.append("")
                tableView.insertRows(at: [IndexPath(row: indexPath.row+1, section: indexPath.section)], with: .top)
                self.tableView.endUpdates()
            }
        } else if editingStyle == .delete {
            tableView.beginUpdates()
            volumes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .bottom)
            tableView.endUpdates()
        }
    }
}

extension OneCustomDrinkTableVC : UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DrinkType.allTypes().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DrinkType.allTypes()[row].text()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        customDrinkType = DrinkType.allTypes()[row]
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AddCustomDrinkCell {
            cell.textField.text = customDrinkType.text()
            myDebugPrint(customDrinkType.text(), "text")
        }
    }
    
}
