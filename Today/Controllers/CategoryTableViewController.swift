//
//  CategoryTableViewController.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/26.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import CoreData
import UIKit

class CategoryTableViewController: UITableViewController {
    var categoryArray: [Category] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: categoryArray[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.parentCategory = categoryArray[indexPath.row]
        }
        
    }
    
    // MARK: - Button Pushed Methods
    
    @IBAction func addCategoryButtonPushed(_ sender: UIBarButtonItem) {
        let alter = UIAlertController(title: "Add New Category", message: "Type a new category", preferredStyle: .alert)
        
        alter.addTextField { alterTextFeild in
            alterTextFeild.placeholder = "New Category"
        }
        
        let newCategoryAction = UIAlertAction(title: "Add", style: .default) { _ in
            let category = Category(context: self.context)
            category.name = alter.textFields?.first?.text
            self.categoryArray.append(category)
            self.saveData()
            self.tableView.reloadData()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alter.addAction(newCategoryAction)
        alter.addAction(cancel)
        
        present(alter, animated: true)
    }
    
    @IBAction func delectAllDataButtonPushed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Delete All Data?", message: "Do You Want To Delete All The Data?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteAllData()
            self.loadData()
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    // MARK: - Data Base Methods
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Fail saving data.Error : \(error)")
        }
    }
    
    func loadData() {
        let requst: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            try categoryArray = context.fetch(requst)
        } catch {
            print("Fail loading data.Error : \(error)")
        }
    }
    
    func deleteAllData() {
        for category in categoryArray {
            context.delete(category)
        }
        saveData()
    }
    
}
