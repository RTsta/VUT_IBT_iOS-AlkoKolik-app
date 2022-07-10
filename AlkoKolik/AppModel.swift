//
//  AppModel.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.04.2021.
//

import Foundation
import UserNotifications

class AppModel {
    
    struct ConcetrationData : Hashable{
        let from : Date
        let to : Date
        let values : [Concentration]
    }
    
    private let model = SimulationAlcoholModel()
    
    // Personal data properties
    //--------------------
    private var personalData : PersonalData?
    
    // Alcohol model data properties
    //--------------------
    var dataSet : [RFactorMethod : ConcetrationData?] = [:]
    var currentBAC : Concentration?
    var peakBAC : Double?
    var soberDate : Date? {didSet{
        if let _soberDate = soberDate, _soberDate > Date(){
            if !Calendar.current.isDate(oldValue ?? Date(), equalTo: _soberDate, toGranularity: .minute){
                    UserNotificationManager.planSoberNotification(for: _soberDate)
            }
        }else {UserNotificationManager.disableSoberNotification()}
    }}
    
    // Favourtite drinks properties
    //--------------------
    lazy var favourites : [FavouriteDrink] = {return UserDefaultsManager.loadFavouriteDrinks() ?? []}()
    lazy var fullFavouriteDrinkItems : [DrinkItem] = {return self.loadFullDrinkItems()}()
    //All drinks properties
    //--------------------
    lazy var customDrinks : [DrinkItem] = { return DrinkItem.createFrom(CoreDataManager.fetchCustomDrinksAll()) }()
    lazy var defaultDrinks : [DrinkItem] = { return DefaultDrinksManager.loadAllDrinks() ?? [] }()
    lazy var listOfAllDrinks : [DrinkItem] = { return customDrinks + defaultDrinks }()
    //-------------------
    //---------------------
    
    init(completion: ((Bool, String)->Void)? = nil) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFavourites), name: .favouriteNeedsReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(favouriteBtnPressed), name: .favouriteBtnPressd, object: nil)
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        loadPersonalData(){ _ in
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main){
            self.simulateAlcoholModel(useMethod: [.average], storeResults: true, complition: nil)
        }
        completion?(true, "nic")
    }
    
    func loadPersonalData(complition: ((Bool)->Void)?){
        HealthKitManager.getPersonalData(){_height,_weight,_age,_sex in
            if let w = _weight, let h = _height, let a = _age, let s = _sex {
                self.personalData = PersonalData(sex: s, height: h, weight: w, age: a)
            }
            complition?(true)
        }
    }
    
    func isPersonalDataAvaibile() -> Bool {
        if personalData != nil { return true }
        else { return false }
    }
    
    func getHeight() -> Measurement<UnitLength> {
        if let _p = personalData {
            return _p.height
        }
        return Measurement(value: 0, unit: .centimeters)
    }
    
    func getWeight() -> Measurement<UnitMass> {
        if let _p = personalData {
            return _p.weight
        }
        return Measurement(value: 0, unit: .kilograms)
    }
    
    func getSex() -> PersonalData.Gender? {
        if let _p = personalData {
            return _p.sex
        }
        return nil
    }
    
    func updateSimulation(complition: (([Concentration]?,Concentration?,Date?,Bool)->Void)? = nil){
        if personalData == nil {loadPersonalData(complition: nil)}
        simulateAlcoholModel(useMethod: [.average],storeResults: true, complition: complition)
    }
    
    func simulateAlcoholModel(from: Date? = nil, to: Date? = nil,
                              withExtraData extraData: [ConsumedDrink] = [],
                              useMethod method: [RFactorMethod],
                              storeResults: Bool,
                              complition: (([Concentration]?,Concentration?,Date?,Bool)->Void)? = nil){
        //complition: ((values: [Concentration]?,peakBAC: Concentration?,soberDate: Date?,succes: Bool)->Void)?
        guard let _ = personalData else { complition?(nil,nil,nil,false);return }
        let _from : Date = from ?? Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let _to : Date = to ?? Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        model.run(personalData: personalData!, from: _from, to: _to,extraData: extraData, method: method){ graphInputs, succes in
            guard succes, let _graphinputs = graphInputs else {print("Error - data were not loaded"); complition?(nil,nil,nil,false);return}
            if storeResults {
                for (key, value) in _graphinputs {
                    dataSet[key] = ConcetrationData(from: _from, to: _to, values: value)
                }
                if dataSet.keys.contains(RFactorMethod.average), let avrg = dataSet[.average]! {
                    currentBAC = findCurrentBAC(inGraph: avrg)
                    peakBAC = findPeakBAC(inGraph: avrg)
                    soberDate = findSoberDate(inGraph: avrg)
                    NotificationCenter.default.post(name: .modelCalculated, object: nil)
                }
            }
            let data = ConcetrationData(from: _from, to: _to, values: _graphinputs[.average]!)
            complition?(data.values, findPeakBAC(inGraph: data),findSoberDate(inGraph: data), true)
        }
    }
    
    @objc func favouriteBtnPressed(){
        updateSimulation(complition: nil)
    }
    
    private func findCurrentBAC(inGraph input: ConcetrationData) -> Concentration{
        let intervalToCurrent = Calendar.current.dateComponents([.minute], from: input.from, to: Date())
        
        if (0 <= (intervalToCurrent.minute ?? -1)) && ((intervalToCurrent.minute ?? 0) < input.values.count) {
            return input.values[intervalToCurrent.minute!]
        }
        return .zero
    }
    
    private func findSoberDate(inGraph input: ConcetrationData) -> Date {
        let intervalToCurrent = Calendar.current.dateComponents([.minute], from: input.from, to: Date())
        if (0 <= (intervalToCurrent.minute ?? -1)) && ((intervalToCurrent.minute ?? 0) < input.values.count) {
            for i in intervalToCurrent.minute!..<input.values.count-1 {
                if input.values[i+1] <= 0 {
                    let timeOfGettingSober = i-intervalToCurrent.minute!
                    return Calendar.current.date(byAdding: .minute, value: timeOfGettingSober, to: Date())!
                }
            }
        }
        return Date()
    }
    
    private func findPeakBAC(inGraph input: ConcetrationData) -> Concentration{
        let intervalToCurrent = Calendar.current.dateComponents([.minute], from: input.from, to: Date())
        
        if (0 <= (intervalToCurrent.minute ?? -1)) && ((intervalToCurrent.minute ?? 0) < input.values.count) {
            var tmpPeak = input.values[intervalToCurrent.minute!] //on index 0 should be result for average method
            for i in stride(from: intervalToCurrent.minute!, to: input.values.count, by: 1){
                if input.values[i] > tmpPeak {tmpPeak = input.values[i]}
            }
            return tmpPeak
        }
        return .zero
    }
    

    
    func findDrinkBy(id: Int) -> DrinkItem? {
        return listOfAllDrinks.first(where: {$0.id == id})
    }
}

//Favourite drink - methods
extension AppModel {
    private func loadFullDrinkItems() -> [DrinkItem]{
        updateCustomDrinks() //they are more likely to be often changed, maybe unefficient, maybe in future refactored to better sollution
        var items : [DrinkItem] = []
        for drink in favourites {
            let elem = listOfAllDrinks.first(where: {$0.id == drink.drinkId})
            ?? DrinkItem(id: -1, name: "", volume: [0], alcoholPercentage: 0, type: .none, active: true)
            items.append(elem)
        }
        return items
    }
    
    @objc func reloadFavourites(){
        if let _defaultsFavourites = UserDefaultsManager.loadFavouriteDrinks(){
            favourites = _defaultsFavourites
            fullFavouriteDrinkItems = self.loadFullDrinkItems()
        }
    }
}

extension AppModel{
    
    func updateCustomDrinks(){
        customDrinks = DrinkItem.createFrom(CoreDataManager.fetchCustomDrinksAll())
        listOfAllDrinks = customDrinks + defaultDrinks
    }
    
    func isDefault(drink: DrinkItem) -> Bool {
        return self.defaultDrinks.contains(where: {$0.id == drink.id})
    }
    func isCustom(drink: DrinkItem) -> Bool {
        return self.customDrinks.contains(where: {$0.id == drink.id})
    }
    func isFavourite(drink: DrinkItem) -> Bool {
        return self.fullFavouriteDrinkItems.contains(where: {$0.id == drink.id})
    }
}
