//
//  HypotheticalModeVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 20.06.2021.
//

import UIKit

struct ConsumedDrink {
    let timestemp : Date?
    let drink_id  : Int32
    let volume : Double
    let grams_of_alcohol : Double
    
    func convert(drinkRecord rec: DrinkRecord) -> ConsumedDrink {
        return ConsumedDrink(timestemp: rec.timestemp, drink_id: rec.drink_id, volume: rec.volume, grams_of_alcohol: rec.grams_of_alcohol)
    }
}

class HypotheticalModeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, HypoMDrinkListDelegate, HypoMStatContainerDelegate {
    
    @IBOutlet weak var consumedTable: UITableView!
    
    var model : AppModel?
    private var rec : [ConsumedDrink] = []
    
    var accountConsumedAlcohol : Bool = false
    
    var hypoMStatsContainer : HypoMStatContainerVC?
    var peakBAC : Double = 0
    var soberDate : Date = Date()
    
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.style = .plain
        button.tintColor = .appButton
        button.title = NSLocalizedString("Delete all", comment: "Delete hypothetical drinks")
        button.target = self
        button.action = #selector(deleteButtonPressed)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let vc = hypoMStatsContainer {
            vc.peakBAC = peakBAC
            vc.soberDate = soberDate
        }
    }
    
    func updateInfo(){
        let from = (accountConsumedAlcohol ? Calendar.current.date(byAdding: .day, value: -3, to: Date())! : Date())
        model?.simulateAlcoholModel(from: from, withExtraData: rec, useMethod: [.average], storeResults: false){
            _ ,peakBAC, soberDate,succes in
            if !succes {return}
            self.peakBAC = peakBAC ?? 0
            self.soberDate = soberDate ?? Date()
            if let vc = self.hypoMStatsContainer {
                vc.peakBAC = self.peakBAC
                vc.soberDate = self.soberDate
            }
        }
    }
    
    @objc func deleteButtonPressed(){
        rec = []
        consumedTable.reloadData()
        updateInfo()
        self.navigationItem.rightBarButtonItem = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HypoMDrinkListContainerVC,
           let _model = model{
            vc.delegate = self
            vc.model = _model
        } else if let vc = segue.destination as? HypoMStatContainerVC {
            hypoMStatsContainer = vc
            vc.delegate = self
        }
    }
    private func createNewAppModel() -> AppModel{
        let new = AppModel()
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = new
        }
        return new
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == consumedTable {
            return rec.count
        } else {return 0}
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == consumedTable {
            return 1
        }
        else {return 0}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "hypotheticalModeRecordCell", for: indexPath) as? TodayDrinkTableCell else { fatalError("Cell is not an instance of TodayDrinkTableCell.") }

        let drink = model?.findDrinkBy(id: Int(rec[indexPath.row].drink_id))
        cell.style = .drink
        cell.backgroundColor = UIColor.colorFor(drinkType: drink?.type ?? DrinkType.none )
        cell.drinkLabel.text = drink?.name ?? ""
        cell.timeLabel.text = "\(indexPath.row + 1)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        return
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            rec.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            updateInfo()
            
            if rec.count == 0 {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView == consumedTable {
            return .delete
        } else {return .none}
    }
    
    func didSelectedDrink(_ drink: DrinkItem, _ volumeIndex: Int) {
        myDebugPrint(drink.volume[volumeIndex], drink.name)

        let v = drink.volume[volumeIndex]
        let z = drink.alcoholPercentage/100
        let a = 1.0
        let d = 0.789
        let dose = v * z * a * d
        rec.append(ConsumedDrink(timestemp: Date(), drink_id: Int32(drink.id), volume: v, grams_of_alcohol: dose))
        updateInfo()
        consumedTable.reloadData()
        consumedTable.scrollToRow(at: IndexPath(row: rec.count-1, section: 0), at: .bottom, animated: true)
        if rec.count > 0 {
            self.navigationItem.rightBarButtonItem = deleteButton
        }
    }
    
    func didSwitchedAccountToggle(to state: Bool) {
        myDebugPrint("zavolano")
        accountConsumedAlcohol = state
        myDebugPrint(state, "switched")
        updateInfo()
    }
}

protocol HypoMDrinkListDelegate : AnyObject {
    func didSelectedDrink(_ drink: DrinkItem,_ volumeIndex: Int)
}

protocol HypoMStatContainerDelegate {
    func didSwitchedAccountToggle(to state: Bool)
}
