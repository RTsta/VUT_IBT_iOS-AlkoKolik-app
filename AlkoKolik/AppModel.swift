//
//  AppModel.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 02.04.2021.
//

import Foundation

class AppModel {
    
    struct ConcetrationData : Hashable{
        let from : Date
        let to : Date
        let values : [Concentration]
    }
    struct PersonalData{
        let sex: Gender
        let height: Measurement<UnitLength>  //meters
        let weight: Measurement<UnitMass>  //kilograms
        let age: Double    //years
    }
    enum Gender {
        case male
        case female
    }
    
    private let model = SimulationAlcoholModel()
    
    private var personalData : PersonalData?
    
    var dataSet : [SimulationAlcoholModel.RFactorMethod : ConcetrationData?] = [:]
    var currentBAC : Concentration?
    var peakBAC : Double?
    var soberDate : Date?
    //--------------------
    lazy var favourites : [FavouriteDrink] = {return UserDefaultsManager.loadFavouriteDrinks() ?? []}()
    lazy var fullDrinkItems : [DrinkItem] = {return self.loadFullDrinkItems()}()
    //--------------------
    lazy var listOfDrinks : [DrinkItem] = {return ListOfDrinksManager.loadAllDrinks() ?? []}()
    //-------------------
    //---------------------
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFavourites), name: .favouriteNeedsReload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(favouriteBtnPressed), name: .favouriteBtnPressd, object: nil)
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        getPersonalData(){
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main){
            self.calculateAlcoholModel(complition: nil)
        }
    }
    
    func getPersonalData(complition: (()->Void)?){
        HealthKitManager.getPersonalData(){_height,_weight,_age,_sex in
            if let w = _weight, let h = _height, let a = _age, let s = _sex {
                self.personalData = PersonalData(sex: s, height: h, weight: w, age: a)
            }
            complition?()
        }
    }
    
    func update(complition: (()->Void)?){
        calculateAlcoholModel(complition: complition)//on complition send notification
    }
    
    func calculateAlcoholModel(complition: (()->Void)?){
        guard let _ = personalData else { return }
        
        let from = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let to = Calendar.current.date(byAdding: .day, value: 2, to: Date())!

        model.run(personalData: personalData!, from: from, to: to) { results, succes in
            guard succes, let modelResults = results else {print("Error - data were not loaded"); return}
            let data = ConcetrationData(from: from, to: to, values: modelResults)
            
            currentBAC = findCurrentBAC(inGraph: data)
            peakBAC = findPeakBAC(inGraph: data)
            soberDate = findSoberDate(inGraph: data)
            dataSet[.average] = data
            NotificationCenter.default.post(name: .modelCalculated, object: nil)
            
            complition?()
        }
    }
    
    
    @objc func favouriteBtnPressed(){
        update(complition: nil)
    }
    
    func simulateMultipleAlcoholModels(complition: (()->Void)? = nil){
        guard let _ = personalData else { return }
        
        let from = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let to = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        
        model.runWithMultipleMethods(personalData: personalData!, from: from, to: to) { graphInputs, succes in
            if succes, let _graphinputs = graphInputs{
                for (key, value) in _graphinputs {
                    dataSet[key] = ConcetrationData(from: from, to: to, values: value)
                }
                if dataSet.keys.contains(SimulationAlcoholModel.RFactorMethod.average), let avrg = dataSet[.average]! {
                    currentBAC = findCurrentBAC(inGraph: avrg)
                    peakBAC = findPeakBAC(inGraph: avrg)
                    soberDate = findSoberDate(inGraph: avrg)
                    NotificationCenter.default.post(name: .modelCalculated, object: nil)
                }
                complition?()
            }
        }
    }
    
    func runModelInCustomPeriod(from: Date, to: Date, complition: (([Double]?,Bool)->Void)? = nil){
        guard let _ = personalData else { return }
        model.run(personalData: personalData!, from: from, to: to) { results, succes in
            guard succes, let modelResults = results else {print("Error - data were not loaded"); complition?(nil,false);return}
            
            complition?(modelResults,true)
        }
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
    
    private func loadFullDrinkItems() -> [DrinkItem]{
        var items : [DrinkItem] = []
        for drink in favourites {
            let elem = ListOfDrinksManager.findDrink(drink_id: drink.drinkId)
                ?? DrinkItem(id: -1, name: "", volume: [0], alcoholPercentage: 0, type: .none)
            items.append(elem)
        }
        return items
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
    
    @objc func reloadFavourites(){
        if let _defaultsFavourites = UserDefaultsManager.loadFavouriteDrinks(){
            favourites = _defaultsFavourites
            fullDrinkItems = self.loadFullDrinkItems()
        }
    }
    
}
