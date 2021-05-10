//
//  UserDefaultsManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 14.03.2021.
//

import Foundation

class UserDefaultsManager {
    
    class func saveFavourite(drinks: [FavouriteDrink]){
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(drinks)
            UserDefaults.standard.setValue(data, forKey: .favouriteDrinkKey)
            print("UserDefaultsManager - favourite drinks were saved")
        }catch let error { print("UserDefaultsManager - Error - \(error.localizedDescription)")}
    }
    
    class func insertIntoFavourite(drinkId id: Int, volume: Double) {
        let newFavourite = FavouriteDrink(drinkId: id, volume: volume)
        var drinks : [FavouriteDrink] = UserDefaultsManager.loadFavouriteDrinks() ?? []
        drinks.append(newFavourite)
        UserDefaultsManager.saveFavourite(drinks: drinks)
        print("UserDefaultManager - drink id: \(id), volume \(volume) - was inserted")
    }
    
    class func loadFavouriteDrinks() -> [FavouriteDrink]? {
        if let data = UserDefaults.standard.data(forKey: .favouriteDrinkKey) {
            do {
                let decoder = JSONDecoder()
                let drinks = try decoder.decode([FavouriteDrink].self, from: data)
                return drinks
            } catch {
                print("UserDefaultsManager - Error - Unable to Decode FavouriteDrinks (\(error))")
            }
        }
        print("UserDefaultsManager - Error - loadFavouriteDrinks - Unable to load UserDefaults")
        return nil
    }
    
    class func deleteFromFavourite(drinkId id: Int, volume: Double){
        let toDelete = FavouriteDrink(drinkId: id, volume: volume)
        var drinks : [FavouriteDrink] = UserDefaultsManager.loadFavouriteDrinks() ?? []
        drinks.removeAll(where: {($0.drinkId == toDelete.drinkId && $0.volume == toDelete.volume)})
        UserDefaultsManager.saveFavourite(drinks: drinks)
        print("UserDefaultManager - drink id: \(id), volume \(volume) - was deleted \n now UD contains: \n\(drinks)")
    }
    
    class func wasWalkthrough() -> Bool {
        return UserDefaults.standard.bool(forKey: .wasWalkthrough)
    }
    
    class func willPresentNextTimeWalkthrough(_ will : Bool) {
        UserDefaults.standard.set(!will, forKey: .wasWalkthrough)
    }
}

private extension String {
    static let favouriteDrinkKey = "favouriteDrinksKey"
    static let wasWalkthrough = "wasWalkthrough"
}
