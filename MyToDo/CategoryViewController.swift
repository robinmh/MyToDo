//
//  CategoryViewController.swift
//  MyToDo
//
//  Created by Robin on 12/10/18.
//  Copyright © 2018 RamonSoftware. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
        let alert = UIAlertController(title: "Add new ToDo category", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // what will happen when the usee clicks the Add Item button
            
            let category = Category(context: self.context)
            
            category.name = textField.text!
         //   item.done = false
            
            if category.name != "" {
                
                self.categoryArray.append(category)
                
                self.saveCategories()
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Describe new item"
            
            textField = alertTextField // store
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveCategories () {
        
        do {
            try context.save()
            
        } catch {
            
            print("Error during saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) { //incude default value
        
        do {
            categoryArray = try context.fetch (request)
        } catch {
            print("Error during reading context \(error)")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        //      cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
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
                    
                    destinationVC.selectedCategory = categoryArray[indexPath.row]
                    
                }
                
            }
            
        }
        
    }
    
    
    //MARK: - Data Manipulation Methods
}
