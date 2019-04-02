//
//  CategoryTableViewController.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/26.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import RealmSwift
import UIKit

class CategoryTableViewController: UITableViewController {
    lazy var realm = try! Realm()
    
    var categoryResults: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryResults = realm.objects(Category.self)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        cell.textLabel?.text = categoryResults?[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryResults?.count ?? 1
    }
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: categoryResults?[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.parentCategory = categoryResults?[indexPath.row]
        }
    }
    
    // MARK: - Button Pushed Methods
    
    @IBAction func addCategoryButtonPushed(_ sender: UIBarButtonItem) {
        let alter = UIAlertController(title: "Add New Category", message: "Type a new category", preferredStyle: .alert)
        
        alter.addTextField { alterTextFeild in
            alterTextFeild.placeholder = "New Category"
        }
        
        let newCategoryAction = UIAlertAction(title: "Add", style: .default) { _ in
            let newCategory = Category()
            newCategory.name = alter.textFields!.first!.text!
            self.saveData(newCategory)
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
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    // MARK: - Data Base Methods
    
    func saveData(_ newCategory: Category) {
        do {
            try realm.write {
                realm.add(newCategory)
            }
        } catch {
            print("Fail saving data.Error : \(error)")
        }
    }
    
    func deleteAllData() {
        try! realm.write {
            realm.deleteAll()
        }
    }
}
