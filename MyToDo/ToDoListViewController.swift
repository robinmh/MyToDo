//
//  ViewController.swift
//  MyToDo
//
//  Created by Robin on 9/10/18.
//  Copyright © 2018 RamonSoftware. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var mySearchBar: UISearchBar!

    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent ("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mySearchBar.delegate = self
    
       loadItems()
    }

//MARk - Tableview DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].name
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
       
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].done  = !itemArray[indexPath.row].done
        
    //    context.delete(itemArray[indexPath.row])  //important: this is done first
        
    //    itemArray.remove (at: indexPath.row)
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Search bar delegate emthods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let mySearch = mySearchBar.text!
        
        DispatchQueue.main.async {
            
            self.mySearchBar.resignFirstResponder()
        }
        
        let request : NSFetchRequest <Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", mySearch)
        
        let sortDescriptor = NSSortDescriptor (key: "name", ascending: true)
        
        request.predicate = predicate
        
        request.sortDescriptors = [sortDescriptor]
        
        do {
            itemArray = try context.fetch (request)
        } catch {
            print("Error during searching context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
          
            loadItems()
            
            tableView.reloadData()
            
            DispatchQueue.main.async {
                    
                self.mySearchBar.resignFirstResponder()
            }
        }
    }
    
    //MARK - add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new ToDo item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // what will happen when the usee clicks the Add Item button
            
            let item = Item(context: self.context)
            
            item.name = textField.text!
            item.done = false
            
            if item.name != "" {
           
                self.itemArray.append(item)
            
                self.saveItems()
            }
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Describe new item"
            
            textField = alertTextField // store
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems () {
        
        do {
            try context.save()
            
        } catch {
            
            print("Error during saving context \(error)")
        }
        
        tableView.reloadData()
    }

    func loadItems() {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()

        do {
            itemArray = try context.fetch (request)
        } catch {
            print("Error during reading context \(error)")
        }
    }
}
