//
//  CoreDataStack.swift
//  AlkoKolik
//
//  Created by Arthur Nácar on 22.03.2021.
//

import CoreData

class CoreDataStack {
    
    private let modelName: String
    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }
    
    static let shared: CoreDataStack = {
        let stack = CoreDataStack(modelName: "AlkoKolik")
        stack.viewContext.automaticallyMergesChangesFromParent = true
        return stack
    }()
    
    private lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
            print(storeDescription)
        })
        return container
    }()
    
    init(modelName: String) {
        self.modelName = modelName
        _ = persistentContainer
    }
}

extension NSManagedObjectContext {
    
    func saveContext() throws {
        guard hasChanges else { return }
        try save()
    }
}
