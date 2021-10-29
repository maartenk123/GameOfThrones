//
//  CoreDataStack.swift
//  Game of Thrones
//
//  Created by Maarten Koe on 20/10/2021.
//

import CoreData
import UIKit

class CoreDataStack {
    
    static let sharedStack = CoreDataStack()
    
    var modelName = "Game_of_Thrones"
    
    // Persistent container to hold the managed object model
    lazy var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: modelName)
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      })
      return container
    }()
    
    // Adding a persistent store for the model
    fileprivate lazy var psc: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(
            managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory
            .appendingPathComponent(modelName)
        do {
            let options =
                [NSMigratePersistentStoresAutomaticallyOption : true]
            
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType, configurationName: nil, at: url,
                options: options)
        } catch  {
            print("Error adding persistent store.")
        }
        return coordinator
    }()
    
    // Base app data url
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    // Managed object model url extension
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main
            .url(forResource: modelName,
                 withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // Create and store new category from dictionary
    func createCategoryEntity(dictionary: [String: Any]) -> Category? {
        let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext

        if let categoryEntity = NSEntityDescription.insertNewObject(forEntityName: "Category", into: managedContext) as? Category {
            categoryEntity.name = dictionary["category_name"] as? String
            categoryEntity.type = dictionary["type"] as! Int64

            return categoryEntity
        }
        return nil
    }
    
    func createBookEntity(dictionary: [String: Any], category: Category) -> Book? {
        let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext

        if let bookEntity = NSEntityDescription.insertNewObject(forEntityName: "Book", into: managedContext) as? Book {
            bookEntity.isbn = dictionary["isbn"] as? String
            bookEntity.name = dictionary["name"] as? String
            bookEntity.category = category
            return bookEntity
        }
        return nil
    }
    
    func createHouseEntity(dictionary: [String: Any], category: Category) -> House? {
        let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext

        if let houseEntity = NSEntityDescription.insertNewObject(forEntityName: "House", into: managedContext) as? House {
            houseEntity.id = dictionary["id"] as? String
            houseEntity.name = dictionary["name"] as? String
            houseEntity.region = dictionary["region"] as? String
            houseEntity.category = category
            return houseEntity
        }
        return nil
    }
    
    func createCharEntity(dictionary: [String: Any], category: Category) -> Char? {
        let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext

        if let charEntity = NSEntityDescription.insertNewObject(forEntityName: "Char", into: managedContext) as? Char {
            charEntity.id = dictionary["id"] as? String
            charEntity.name = dictionary["name"] as? String
            charEntity.category = category
            return charEntity
        }
        return nil
    }
    
    func clearCategory(category: Category) {
        let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext
        
        
        do {
            for book in category.books ?? [] {
            try managedContext.delete(book as! Book)
        }
        
        try managedContext.save()
        } catch let error {
            print("Error deleting: \(error)")
        }

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        let predicate = NSPredicate(format: "type == %i", category.type)
        fetchRequest.predicate = predicate

        do {
            let result = try managedContext.fetch(fetchRequest) as? [Category]
            category.mutableSetValue(forKey: "books").removeAllObjects()
            if result!.count > 0 {
                let resultCategory = result![0]
                
                for book in resultCategory.books ?? [] {
                    managedContext.delete(book as! Book)
                }
                for house in resultCategory.houses ?? [] {
                    managedContext.delete(house as! House)
                }
                for char in resultCategory.chars ?? [] {
                    managedContext.delete(char as! Char)
                }

                try managedContext.save()
            }
        } catch let error {
            print("Error deleting: \(error)")
        }
    }

    func saveContext() {
        let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext

        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch let error {
                print("Error: \(error)")
                abort()
            }
        }
    }
}
