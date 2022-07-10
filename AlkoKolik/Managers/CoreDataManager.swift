//
//  CoreDataManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit
import CoreData

class CoreDataManager {
    
    class func insertRecord(drink: DrinkItem, volumeOpt: Int ,time: Date, volumeMl: Double? = nil){
        guard let managedContext = getContext() else {return}
        let newRecord = DrinkRecord(context: managedContext)
        
        /*
         D = (volume * z * a * d) - dose of drinken alcohol
         z - percentage / 100
         a - proportion of the alcohol absorbed
         d - alcohol density
         */
        var v : Double?
        if let _ = volumeMl {v = volumeMl!} else {v = drink.volume[volumeOpt]}
        guard let _ = v else {print("CoreDataManager - Error - volume is nil");return}
        let z = drink.alcoholPercentage/100
        let a = 1.0
        let d = 0.789
        let dose = v! * z * a * d
        // TODO: nebude používat strukturu z CoreData
        newRecord.timestemp = time
        newRecord.drink_id = Int32(drink.id)
        newRecord.volume = v!
        newRecord.grams_of_alcohol = dose
        
        saveContext(managedContext)
        print("CoreDataManager - \(time) \(drink.name), \(v ?? 0) inserted!")
    }
    
    class func deleteRecord(record: NSManagedObject) {
        guard let managedContext = getContext() else {return}
        managedContext.delete(record)
        saveContext(managedContext)
    }
    
    class func fetchRecordsBetween(from: Date, to: Date) -> [DrinkRecord]{
        var records : [DrinkRecord] = []
        guard let managedContext = getContext() else {return records}
        let request : NSFetchRequest<DrinkRecord> = DrinkRecord.fetchRequest()
        request.predicate = predicateForBetween(from, to)
        do {
            records = try managedContext.fetch(request) as [DrinkRecord]
        } catch let error as NSError {
            print("CoreDataManager - Error - Could not fetch. \(error), \(error.userInfo)")
        }
        return records
    }
    
    class func fetchRecordsAll() -> [DrinkRecord] {
        var records : [DrinkRecord] = []
        guard let managedContext = getContext() else {return records}
        let request : NSFetchRequest<DrinkRecord> = DrinkRecord.fetchRequest()
        do {
            records = try managedContext.fetch(request) as [DrinkRecord]
        } catch let error as NSError {
            print("CoreDataManager - Error - Could not fetch. \(error), \(error.userInfo)")
        }
        return records
    }
    
    private class func getContext() -> NSManagedObjectContext?{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
        return appDelegate.persistentContainer.viewContext
    }
    
    private class func saveContext(_ context: NSManagedObjectContext){
        do { try context.save()
        }catch let error as NSError {
            fatalError("CoreDataManager - Error - Couldnt delete object \(error.code) \n\n \(error.localizedDescription)")
        }
    }
    
    private class func predicateForBetween(_ from: Date,_ to: Date) -> NSPredicate{
        return NSPredicate(format:"timestemp >= %@ AND timestemp < %@", from as NSDate, to as NSDate)
    }
    
    class func updateCustomDrinks(of drink: DrinkItem, name: String? = nil, drinkType: DrinkType? = nil, percentage: Double? = nil, volumes: [Double]? = nil, active: Bool? = nil){
        var customDrinks : [CustomDrink] = []
        guard let managedContext = getContext() else {return}
        let request : NSFetchRequest<CustomDrink> = CustomDrink.fetchRequest()
        request.predicate = NSPredicate(format: "drink_id == %i", drink.id)
        do {
            customDrinks = try managedContext.fetch(request) as [CustomDrink]
        } catch let error as NSError {
            print("CoreDataManager - Error - Could not fetch. \(error), \(error.userInfo)")
        }
        let resultToUpdate = customDrinks.first
        
        if let _name = name { resultToUpdate?.name = _name }
        if let _type = drinkType { resultToUpdate?.type = _type.getString().lowercased() }
        if let _percentage = percentage { resultToUpdate?.percentage = _percentage }
        if let _volumes = volumes { resultToUpdate?.volumes = _volumes }
        if let _active = active { resultToUpdate?.active = _active }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("CoreDataManager - Error - Could not save. \(error), \(error.userInfo)")
        }
        print("CoreDataManager - \(Date()) - CustomDrink: \(drink.name) updated to \(String(describing: name)), \(String(describing: drinkType?.text())), \(String(describing: percentage)), \(String(describing: volumes)), \(String(describing: active)),\(name ?? "")!")
        
    }
    
    class func fetchCustomDrinksAll() -> [CustomDrink]{
        var customDrinks : [CustomDrink] = []
        guard let managedContext = getContext() else {return customDrinks}
        let request : NSFetchRequest<CustomDrink> = CustomDrink.fetchRequest()
        do {
            customDrinks = try managedContext.fetch(request) as [CustomDrink]
        } catch let error as NSError {
            print("CoreDataManager - Error - Could not fetch. \(error), \(error.userInfo)")
        }
        return customDrinks
    }
    
    class func insertCustomDrink(name: String, type: DrinkType, percentage: Double, volumes: [Double]){
        let ids = fetchCustomDrinksAll().compactMap({ $0.drink_id })
        let id = ids.max() ?? (666000000-1) //number, from where all records should be custom
        
        guard let managedContext = getContext() else {return}
        let newCustomDrink = CustomDrink(context: managedContext)
        
        newCustomDrink.drink_id = id+1
        newCustomDrink.name = name
        newCustomDrink.type = type.getString().lowercased()
        newCustomDrink.percentage = percentage
        newCustomDrink.volumes = volumes
        newCustomDrink.active = true

        saveContext(managedContext)
        print("CoreDataManager - \(Date()) - CustomDrink: \(newCustomDrink.name ?? "") inserted!")
    }
}
