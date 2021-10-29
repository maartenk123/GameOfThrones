//
//  CategoriesViewController.swift
//  Game of Thrones
//
//  Created by Maarten Koe on 22/10/2021.
//

import UIKit
import CoreData


class CategoryListViewController: UITableViewController {
    
    let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext
    var selectedCategory: Category?
    
    // FetchedResultsController updates the tableView with fetched data
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Category.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        loadCategories()
    }
    
    func loadCategories() {
        // Get categories that are stored locally
        do {
            try self.fetchedResultsController.performFetch()
            print("Fetched objects: \(self.fetchedResultsController.sections![0].numberOfObjects)")
        } catch let error  {
            print("Error: \(error)")
        }
        
        // Get categories if there are none stored locally
        if self.fetchedResultsController.sections![0].numberOfObjects == 0 {
            
            // Get new data from endpoint
            apiService.getCategories { (result) in
                switch result {
                case .Success(let data):
                    self.saveCategories(array: data)
                case .Error(let error):
                    print("Error getting categories: \(error)")
                }
            }
        }
    }
    
    private func saveCategories(array: [Any]) {
        _ = array.map{CoreDataStack.sharedStack.createCategoryEntity(dictionary: $0 as! [String : AnyObject])}
        do {
            try managedContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func saveBooks(array: [Any]) {
        _ = array.map{CoreDataStack.sharedStack.createBookEntity(dictionary: $0 as! [String : AnyObject], category: selectedCategory!)!}
        do {
            try managedContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func saveHouses(array: [Any]) {
        _ = array.map{CoreDataStack.sharedStack.createHouseEntity(dictionary: $0 as! [String : AnyObject], category: selectedCategory!)!}
        do {
            try managedContext.save()
        } catch let error {
            print(error)
        }
    }
    
    private func saveChars(array: [Any]) {
        _ = array.map{CoreDataStack.sharedStack.createCharEntity(dictionary: $0 as! [String : AnyObject], category: selectedCategory!)!}
        do {
            try managedContext.save()
        } catch let error {
            print(error)
        }
    }
    
    // MARK: TableView functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = fetchedResultsController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        if let category = fetchedResultsController.object(at: indexPath) as? Category {
            cell.textLabel?.text = category.name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let category = fetchedResultsController.object(at: indexPath) as? Category {
            print("selected category: \(String(describing: category.name)) with type: \(category.type)")
            
            selectedCategory = category
            
            // Get items for category
            apiService.getList(categoryType: category.type, completion: { (result) in
                switch result {
                case .Success(let data):
                    CoreDataStack.sharedStack.clearCategory(category: self.selectedCategory!)
                    switch category.type {
                    case 0:
                        self.saveBooks(array: data)
                    case 1:
                        self.saveHouses(array: data)
                    case 2:
                        self.saveChars(array: data)
                    default:
                        print("Unknown item type: \(category.type)")
                    }
//                    self.saveInCoreDataWith(array: data)
                case .Error(let message):
                    print("Error getting items: \(message)")
                }
            })
            
            
            // Move to category detail view
            performSegue(withIdentifier: "itemsSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "itemsSegue") {
            let vc = segue.destination as! ItemListViewController
            vc.selectedCategory = selectedCategory
            vc.navigationItem.title = selectedCategory?.name
        }
    }
}


extension CategoryListViewController: NSFetchedResultsControllerDelegate {
    
    // Update tableView with fetched category data
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if (tableView.window != nil) {
            tableView.beginUpdates()
        }
    }
}

