//
//  SettingsVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 15.03.2021.
//

import Foundation
import UIKit
import HealthKit

class SettingsVC: UITableViewController  {
    
    var model1 : AppModel?
    
    var lastBACSync : Date = Date(timeIntervalSince1970: 0) {
        didSet{ super.tableView.reloadData() }
    }
    
    lazy var dateFormater : DateFormatter = {
        let dateformater = DateFormatter()
        dateformater.dateStyle = .medium
        dateformater.timeStyle = .short
        return dateformater
    }()

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLastUploadedData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLastUploadedData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HypotheticalModeVC {
            vc.model = model1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell.reuseIdentifier == "settings_cell_sync_info",
           let cell = cell as? SettingsSyncCell {
            cell.dateLabel.text = "\(NSLocalizedString("Last sync:", comment: "Last import to Apple Health")) \(syncDateToString(date: self.lastBACSync))"
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.cellForRow(at: indexPath)?.reuseIdentifier {
        case "settings_cell_clear_all":
            UserDefaultsManager.saveFavourite(drinks: [])
        case "settings_cell_show_walkthrough":
            let storyboard = UIStoryboard(name: "Walkthrough", bundle: nil)
            if let _walkthroughVC = storyboard.instantiateViewController(identifier: "WalkthroughVC") as? WalkthroughVC{
                present(_walkthroughVC, animated: true, completion: nil)
            }
        case "settings_cell_sync_info":
            guard let cell = tableView.cellForRow(at: indexPath) as? SettingsSyncCell else {break}
            if cell.cellState == .normal {
                cell.cellState = .loading
                
                var last30days = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
                last30days = Calendar.current.date(bySetting: .minute, value: 0, of: last30days)!
                let startFrom = last30days < lastBACSync ? lastBACSync : last30days
                
                model1?.simulateAlcoholModel(from: startFrom, to: Date(), useMethod: [.average], storeResults: false){resultValues,_,_,succes in
                    if !succes {print{"SettingsVC - Error - in making custom model"}; return}
                    guard let resultValues = resultValues else {print{"SettingsVC - Error - in making custom model"}; return}
                    for i in stride(from: 10, to: resultValues.count, by: 10) {
                        let value = resultValues[i] / 1000
                        HealthKitManager.insertBAC(bac: value, forDate: Calendar.current.date(byAdding: .minute, value: i, to: startFrom)!)
                    }
                    cell.cellState = .finished
                    self.checkLastUploadedData()
                }
            }
        case "settings_cell_hypothetical_mode":
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.appText
    }
    
    func checkLastUploadedData(){
        HealthKitManager.getMostRecentBACSample{ recentSample, error in
            if let _error = error {
                print("SettingsVS - Error - couldnt load recent BAC sample - \(_error.localizedDescription)")
            }
            guard let recentSample = recentSample else {
                print("SettingsVS - Error - recentSample is nil"); return
            }
            self.lastBACSync = recentSample.endDate
        }
    }
    
    func syncDateToString(date: Date) -> String{
        if date == Date(timeIntervalSince1970: 0){
            return NSLocalizedString("never", comment: "when was the last update to HealthKit")
        }else {
            return self.dateFormater.string(from: self.lastBACSync)
        }
    }
}
