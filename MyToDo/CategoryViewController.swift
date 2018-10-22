//
//  CategoryViewController.swift
//  MyToDo
//
//  Created by Robin on 12/10/18.
//  Copyright © 2018 RamonSoftware. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()

        tableView.rowHeight = 80.0
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
        let alert = UIAlertController(title: "Add new ToDo category", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // what will happen when the usee clicks the Add Item button
            
            let category = Category()
            
            category.name = textField.text!
            
            if category.name != "" {
                
                self.saveCategories(category)
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Describe new item"
            
            textField = alertTextField // store
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveCategories (_ category: Category) {
        
        do {
            try realm.write {
                
                realm.add(category)
            }
            
        } catch {
            
            print("Error during saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return categories?.count ?? 1 //Nil Coalescing Operator
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added" //nil coalescing operator
        
        cell.delegate = self
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "gotoItems" {
            
            if let destinationVC = segue.destination as? ToDoListViewController {
                
                if let indexPath = tableView.indexPathForSelectedRow {
                    
                    destinationVC.selectedCategory = categories?[indexPath.row]
                }
            }
        }
    }
}

extension CategoryViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil}
        
        let deleteAction = SwipeAction (style: .destructive, title: "Delete") { action, indexPAth in
            
            if let category = self.categories?[indexPath.row] {
                
                do {
                    try self.realm.write {

                            self.realm.delete(category)
                    }
                } catch {
                    print("Error deleteing category \(error)")
                }
                
                tableView.reloadData()
            }
        }
        
        deleteAction.image = UIImage (named: "Delete_Icon")
        
        return [deleteAction]
    }
}
