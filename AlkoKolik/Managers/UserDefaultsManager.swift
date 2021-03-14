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
            print("Inserted favourite drinks")
        }catch let error { print("\(error.localizedDescription)")}
    }
    
    func insertIntoFavourite(drinkId id: Int, volume: Double) {
        let newFavourite = FavouriteDrink(drinkId: id, volume: volume)
        var drinks : [FavouriteDrink] = UserDefaultsManager.loadFavouriteDrinks() ?? []
        drinks.append(newFavourite)
        UserDefaultsManager.saveFavourite(drinks: drinks)
    }
    
    class func loadFavouriteDrinks() -> [FavouriteDrink]? {
        if let data = UserDefaults.standard.data(forKey: .favouriteDrinkKey) {
            do {
                let decoder = JSONDecoder()
                let drinks = try decoder.decode([FavouriteDrink].self, from: data)
                return drinks
            } catch {
                print("Unable to Decode FavouriteDrinks (\(error))")
            }
        }
        return nil
    }
}

private extension String {
    static let favouriteDrinkKey = "favouriteDrinksKey"
}
