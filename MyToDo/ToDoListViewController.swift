//
//  ViewController.swift
//  MyToDo
//
//  Created by Robin on 9/10/18.
//  Copyright © 2018 RamonSoftware. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent ("Items.plist")
    
    //let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        tableView.cellForRow(at: indexPath)?.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new ToDo item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // what will happen when the usee clicks the Add Item button
            
            let item = Item()
            
            item.name = textField.text!
           
            self.itemArray.append(item)
            
            self.saveItems()
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Describe new item"
            
            textField = alertTextField // store
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems () {
        
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            
            try data.write (to: dataFilePath!)
            
        } catch {
            
            print("Error encoding item array \(error)")
        }
    }

    func loadItems() {
        
       if let data = try? Data(contentsOf: dataFilePath!) {
        
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error reading data \(error)")
            }
        }
    }
}
