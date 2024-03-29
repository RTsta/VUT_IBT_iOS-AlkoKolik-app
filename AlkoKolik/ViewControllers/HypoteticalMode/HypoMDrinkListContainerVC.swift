//
//  HypoMDrinkListContainerVC.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 10.10.2021.
//

import UIKit

class HypoMDrinkListContainerVC : UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, HypoMDrinkListCellDelegate {
    
    weak var delegate: HypoMDrinkListDelegate?
    
    var model : AppModel?
    
    private var listOfDrinks = [[DrinkItem]]()
    private var flatternListOfDrinkIds : [Int] = []
    private var categoriesOfDrinks = [DrinkType]()
    var selectedVolumes : [Int] = [Int]()
    
    var expandedDrink : DrinkItem? = nil
    
    lazy var picker : UIPickerView = {
        let picker = UIPickerView()
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        return picker
    }()
    
    lazy var toolbar : UIToolbar = {
        let toolbar = UIToolbar()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done , target: self, action: #selector(doneButtonPressed))
        toolbar.barStyle = .black
        toolbar.isTranslucent = true
        toolbar.setItems([doneBtn], animated:true)
        return toolbar
    }()
    
    lazy var blurView : UIVisualEffectView = {
        var blurView = UIVisualEffectView()
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myDebugPrint( "loaded")
        tableView.allowsSelection = false
        loadListOfDrinks()
        
        picker.dataSource = self
        picker.delegate = self
        
        toolbar.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50)
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        blurView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadListOfDrinks()
    }
    
    private func createNewAppModel() -> AppModel{
        let new = AppModel()
        if let parrent = tabBarController as? MainTabBarController{
            parrent.model = new
        }
        return new
    }
    
    private func loadListOfDrinks(){
        var result : [[DrinkItem]] = []
        var _flatternListOfDrinkIds : [Int] = []
        var _selectedVolumes : [Int] = []
        guard let model = model else {return}
        var drinks = model.listOfAllDrinks
        drinks.sort(by: {$0.name < $1.name})
        drinks.sort(by: {model.isCustom(drink: $0) && !model.isCustom(drink: $1 )})
        drinks.sort(by: {$0.type < $1.type})
        
        var cat = Set<DrinkType>()
        for drink in drinks { cat.insert(drink.type) }
        categoriesOfDrinks = Array(cat).sorted(by: { $0.text() < $1.text() })
        
        for _ in categoriesOfDrinks { result.append( [DrinkItem]() ) }
        
        for drink in drinks {
            result[categoryToInt(drink.type)].append(drink)
            _flatternListOfDrinkIds.append(drink.id)
            _selectedVolumes.append(0)
        }
        selectedVolumes=_selectedVolumes
        listOfDrinks = result
        flatternListOfDrinkIds = _flatternListOfDrinkIds
        self.tableView.reloadData()
    }
    
    private func findDrink(by id: Int) -> DrinkItem?{
        for drinkCategory in listOfDrinks {
            for drink in drinkCategory {
                if drink.id == id { return drink } else {continue}
            }
        }
        return nil
    }
    
    private func categoryToInt(_ elem: DrinkType) -> Int{
        return categoriesOfDrinks.firstIndex(of: elem) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfDrinks[section].count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listOfDrinks.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return categoriesOfDrinks.map{$0.firstLetter()}
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoriesOfDrinks[section].text()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "drinkListCell", for: indexPath) as? HypoMDrinkListCell else { fatalError("Cell is not an instance of DrinkListCell.") }
        
        let oneDrink = listOfDrinks[indexPath.section][indexPath.row]
        cell.type = oneDrink.type
        cell.labelText.text = oneDrink.name
        cell.volumeButton.setTitle("\(oneDrink.volume[selectedVolumes[flatternListOfDrinkIds.firstIndex(of: oneDrink.id)!]])ml", for: .normal)
        cell.delegate = self
        
        cell.drink_id = oneDrink.id
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.appBackground
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.appText
    }
    
    func selectedVolumeChanged(at drink: Int, for index: Int) {
        selectedVolumes[flatternListOfDrinkIds.firstIndex(of: drink)!] = index
        myDebugPrint(index)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let drink = expandedDrink {
            return drink.volume.count
        } else {return 0}
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let drink = expandedDrink {
            return "\(drink.volume[row])ml"
        } else {return ""}
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let drink = expandedDrink {
            
            selectedVolumes[flatternListOfDrinkIds.firstIndex(of: drink.id)!] = row
        }
    }
    
    
    func volumeButtonPressed(withId drink: Int){
        if let _drink = findDrink(by: drink) {
            delegate?.didSelectedDrink(_drink, selectedVolumes[flatternListOfDrinkIds.firstIndex(of: _drink.id)!])
        }
    }
    
    func expandButtonPressed(at drink: Int){
        guard let _drink = findDrink(by: drink) else {fatalError("shouldnt be nil")}
        expandedDrink = _drink
        
        var window : UIWindow?
        
        //https://stackoverflow.com/questions/57134259/how-to-resolve-keywindow-was-deprecated-in-ios-13-0
        window = UIApplication
        .shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
        
        guard let window = window else {return}
        picker.reloadAllComponents()
        picker.selectRow(selectedVolumes[flatternListOfDrinkIds.firstIndex(of: expandedDrink?.id ?? 0) ?? 0], inComponent: 0, animated: false)
        window.addSubview(blurView)
        window.addSubview(picker)
        window.addSubview(toolbar)
    }
    
    @objc func doneButtonPressed(){
        tableView.reloadData()
        toolbar.removeFromSuperview()
        picker.removeFromSuperview()
        blurView.removeFromSuperview()
    }
    
}

protocol HypoMDrinkListCellDelegate : AnyObject {
    func selectedVolumeChanged(at drink: Int, for index: Int)
    func volumeButtonPressed(withId drink: Int)
    func expandButtonPressed(at drink: Int)
}
