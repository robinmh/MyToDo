//
//  ViewController.swift
//  MyToDo
//
//  Created by Robin on 9/10/18.
//  Copyright © 2018 RamonSoftware. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ToDoListViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    var items : Results<Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80
        
        loadItems()
    }

//MARk - Tableview DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath) as! SwipeTableViewCell
        
        if let item = items?[indexPath.row] {
            
            cell.textLabel?.text = item.title
        
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            
            cell.textLabel?.text = "No items defined"
        }
        
        cell.delegate = self
       
        return cell
    }
    
    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         if let item = items?[indexPath.row] {
            do {
                try realm.write {
                   item.done  = !item.done
 //                   realm.delete(item)  //optional delete
                }
            } catch {
                print ("Error saving done status \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add new ToDo item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            // what will happen when the usee clicks the Add Item button
            
            if let category = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let item = Item()
            
                        item.title = textField.text!
                
                        if item.title != "" {
            
                            category.items.append(item) // add to category list
                        }
                    }
                } catch {
                    print ("Error saving item \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Describe new item"
            
            textField = alertTextField // store
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadItems() {
        
        items = selectedCategory?.items.sorted (byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }

}

 //MARK - Search bar delegate methods

extension ToDoListViewController:  UISearchBarDelegate, SwipeTableViewCellDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let search = searchBar.text!
        
        items = items?.filter("title CONTAINS[cd] %@", search).sorted(byKeyPath: "title", ascending: true)
        
        DispatchQueue.main.async {
            
            self.searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            
            loadItems()
            
            DispatchQueue.main.async {
                
                self.searchBar.resignFirstResponder()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil}
        
        let deleteAction = SwipeAction (style: .destructive, title: "Delete") { action, indexPAth in
            
            if let category = self.items?[indexPath.row] {
                
                do {
                    try self.realm.write {
                        
                        self.realm.delete(category)
                    }
                } catch {
                    print("Error deleteing item \(error)")
                }
                
                tableView.reloadData()
            }
        }
        
        deleteAction.image = UIImage (named: "Delete_Icon")
        
        return [deleteAction]
    }
}
