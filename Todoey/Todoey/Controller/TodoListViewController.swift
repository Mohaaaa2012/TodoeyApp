//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//"",
//"Destroy Demogorgon"]

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        //print the path of the storage file Items.plist
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // use dequeueReusableCell rather than UITableViewCell because we need to reuse our existing cells not creating new cell each time
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        // Ternery Operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        cell.accessoryType  = item.done ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Swap the value of property @done
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        // Deselect the background highlight of pressed cell
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Itema
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = alertAction()
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func alertAction() -> UIAlertController {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default)
        { (action) in
            // What will happen when the user clicks the add item button on the UIAlert
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        alert.addTextField
        { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        return alert
    }
    
    func saveItems(){
        
        do{
            try context.save()
        }catch{
            print("Error saving context, \(error)")
        }
        tableView.reloadData()
    }
    
    
    // NSFetchRequest<Item> = Item.fetchRequest()-->> make a default value if the call doesn't have parameter section loadItems()
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        
        
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // make the request
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        // make the query
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //        //attach the query to the request
        //        request.predicate = predicate
        // make ascending sort by title
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //attach the sort to the request
        request.sortDescriptors = [sortDescriptor]
        
        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                // remove cursor and the keyboard
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}




