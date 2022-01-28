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
}
