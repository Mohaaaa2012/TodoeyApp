//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Apple on 8/31/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryItemsArr = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        loadCategoryItems()
        tableView.separatorStyle = .none
    }
    
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        print(sender)
        let alert = alertAction()
        present(alert, animated: true, completion: nil)
    }
    
    func alertAction() -> UIAlertController{
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default)
        { (action) in
            
            let newItem = Category(context: self.context)
            newItem.name = textField.text
            self.categoryItemsArr.append(newItem)
            self.saveCategoryItems()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        return alert
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItemsArr.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        let categoryItem = categoryItemsArr[indexPath.row]
        
        cell.textLabel?.text = categoryItem.name
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "goToItems"{
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categoryItemsArr[indexPath.row]
            }
        }
    }
    //MARK: - Data Manipulation Methods
    
    func loadCategoryItems(with request : NSFetchRequest<Category> = Category.fetchRequest()){
        
        do{
            categoryItemsArr = try context.fetch(request)
        }catch{
            print("Error fetching data, \(error)")
        }
        tableView.reloadData()
    }
    
    func saveCategoryItems() {
        
        do{
            try context.save()
        }catch{
            print("Error save data, \(error)")
        }
        tableView.reloadData()
    }
    
}
