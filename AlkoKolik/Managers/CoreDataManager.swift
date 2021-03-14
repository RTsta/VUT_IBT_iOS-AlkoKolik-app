//
//  CoreDataManager.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 12.03.2021.
//

import UIKit
import CoreData

class CoreDataManager {
    
    class func insertRecord(drink: DrinkItem, volumeOpt: Int ,time: Date){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let newRecord = DrinkRecord(context: managedContext)
        
        /*
         D = (volume * z * a * d) - dose of drinken alcohol
         z - percentage / 100
         a - proportion of the alcohol absorbed
         d - alcohol density
         */
        let v = drink.volume[volumeOpt]
        let z = drink.alcoholPercentage/100
        let a = 1.0
        let d = 0.789
        
        let dose = v * z * a * d
        
        newRecord.timestemp = time
        newRecord.drink_id = Int32(drink.id)
        newRecord.volume = drink.volume[volumeOpt]
        newRecord.grams_of_alcohol = dose
        
        do {
          try managedContext.save()
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        print("\(time) \(drink.name) inserted!")
    }
    
    class func fetchAllRecords() -> [NSManagedObject] {
        var records : [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return records }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<DrinkRecord> = DrinkRecord.fetchRequest()
        do {
            records = try managedContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return records
    }
    
    class func deleteRecord(record: NSManagedObject) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(record)
        do {
            try managedContext.save()
        }catch let error as NSError {
            fatalError("Couldnt delete object \(error.code) \n\n \(error.localizedDescription)")
        }
    }
    
    class func fetchRecordsForDay(day: Date) -> [NSManagedObject]{
        var records : [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return records}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<DrinkRecord> = DrinkRecord.fetchRequest()
        let predicate = predicateForWholeDay(date: day)
        request.predicate = predicate
        do {
            records = try managedContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return records
    }
    
    private class func predicateForWholeDay(date: Date) -> NSPredicate{
        let dayBegining = Calendar.current.startOfDay(for: date)
        let dayEnding = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
        
        return NSPredicate(format:"timestemp >= %@ AND timestemp < %@", dayBegining as NSDate, dayEnding as NSDate)
    }
    
    class func fetchRecordsForWeekPastAndNext(dayOfTheWeek day: Date) -> [NSManagedObject]{
        var records : [NSManagedObject] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return records}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<DrinkRecord> = DrinkRecord.fetchRequest()
        let predicate = predicateForWeekPastAndNext(date: day)
        request.predicate = predicate
        do {
            records = try managedContext.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return records
    }
    
    private class func predicateForWeekPastAndNext(date: Date) -> NSPredicate{

        let past = Calendar.current.date(byAdding: .day, value: -7, to: date)!
        let next = Calendar.current.date(byAdding: .day, value: 7, to: date)!
        
        return NSPredicate(format:"timestemp >= %@ AND timestemp < %@", past as NSDate, next as NSDate)
    }
}
