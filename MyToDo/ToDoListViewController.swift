//
//  ViewController.swift
//  MyToDo
//
//  Created by Robin on 9/10/18.
//  Copyright © 2018 RamonSoftware. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent ("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //    searchBar.delegate = self done in StoryBoard
    
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

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) { //incude default value

        do {
            itemArray = try context.fetch (request)
        } catch {
            print("Error during reading context \(error)")
        }
        
        tableView.reloadData()
    }
}

 //MARK - Search bar delegate methods

extension ToDoListViewController:  UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let search = searchBar.text!
        
        DispatchQueue.main.async {
            
            self.searchBar.resignFirstResponder()
        }
        
        let request : NSFetchRequest <Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", search)
        
        request.sortDescriptors = [NSSortDescriptor (key: "name", ascending: true)]
        
        loadItems(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                
                self.searchBar.resignFirstResponder()
            }
        }
    }
}
