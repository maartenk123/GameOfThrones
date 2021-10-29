//
//  CategoriesViewController.swift
//  Game of Thrones
//
//  Created by Maarten Koe on 26/10/2021.
//

import UIKit
import CoreData


class ItemListViewController: UITableViewController {
    
    let managedContext = CoreDataStack.sharedStack.persistentContainer.viewContext
    var selectedCategory: Category?
    
    // FetchedResultsController updates the tableView with fetched data
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        var itemType: Any = Book.self
        switch selectedCategory?.type {
        case 0:
            itemType = Book.self
        case 1:
            itemType = House.self
        case 2:
            itemType = Char.self
        default:
            itemType = Book.self
        }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: itemType))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let predicate = NSPredicate(format: "category = %@", selectedCategory!)
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TableView setup
        tableView.delegate = self
        tableView.dataSource = self
        
        loadItems()
    }
    
    func loadItems() {
        // Get items that are stored locally
        do {
            try self.fetchedResultsController.performFetch()
            print("Fetched objects: \(self.fetchedResultsController.sections![0].numberOfObjects)")
        } catch let error  {
            print("Error: \(error)")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemCell
        
        if let book = fetchedResultsController.object(at: indexPath) as? Book {
            cell.label?.text = book.name
        } else
        if let house = fetchedResultsController.object(at: indexPath) as? House {
            cell.label?.text = house.name
            cell.setHouseImage(regionName: house.region ?? "")
        } else
        if let char = fetchedResultsController.object(at: indexPath) as? Char {
            cell.label?.text = char.name
        }
        return cell
    }
}


extension ItemListViewController: NSFetchedResultsControllerDelegate {
    
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
        UIView.performWithoutAnimation {
            self.tableView.endUpdates()
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if (tableView.window != nil) {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
            }
        }
    }
}

