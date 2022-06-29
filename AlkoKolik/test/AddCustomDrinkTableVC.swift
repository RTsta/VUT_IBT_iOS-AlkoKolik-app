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
class AddCustomDrinkTableVC: UITableViewController  {
    
    var customDrinkName : String = ""
    var customDrinkType : DrinkType = .none
    var customDrinkPercentage : String = ""
    var volumes : [String] = []
    
    lazy var typePickerView : UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isEditing = true
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
        if indexPath.section == 1 && indexPath.row == volumes.count{
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
            case 1:
                cell.textField.placeholder = "Type"
                cell.textField.text = customDrinkType.text()
                cell.textField.inputView = typePickerView
                cell.textField.tintColor = .clear
            case 2:
                cell.textField.placeholder = "%"
                cell.textField.text = customDrinkPercentage
                cell.textField.keyboardType = .decimalPad
            default:
                break
            }
        case 1:
            cell.textField.keyboardType = .decimalPad
            cell.textField.placeholder = "volume"
            cell.textField.isEnabled = true
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

extension AddCustomDrinkTableVC : UIPickerViewDataSource, UIPickerViewDelegate {
    
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
        }
    }
    
}
