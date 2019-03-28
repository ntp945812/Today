//
//  ViewController.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/17.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import CoreData
import UIKit

class ToDoListViewController: UITableViewController {
    let defults = UserDefaults.standard

    var itemArray = [Item]()
    var parentCategory: Category? {
        didSet {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            loadData(with: request)
            tableView.reloadData()
        }
    }

    let filepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].checked == false ? .none : .checkmark
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    // MARK: - Tableview Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = itemArray[indexPath.row].checked == false ? .none : .checkmark
        saveData()
    }

    // MARK: - Add New Items

    @IBAction func addItemButtomPushed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a todo to the list", message: "", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Cteate New Item"
        }

        let action = UIAlertAction(title: "Add ", style: .default) { _ in
            if alert.textFields?.first?.text != "" {
                let item = Item(context: self.context)
                item.title = alert.textFields?.first?.text
                item.toCategory = self.parentCategory
                self.itemArray.append(item)
                // self.defults.set(self.itemArray, forKey: "ToDoListItemArray")
                self.saveData()
                self.tableView.reloadData()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(cancel)
        alert.addAction(action)

        present(alert, animated: true)
    }

    // MARK: -delete All Data

    @IBAction func deleteAllDataButtonPushed(_ sender: UIBarButtonItem) {
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

    // MARK: - Manage Data Methods

    func saveData() {
        do {
            try context.save()
        } catch {
            print("Fail Saving data. Error : \(error)")
        }
    }

    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
//        let request = NSFetchRequest<NSManagedObject>(entityName: "Item")
//
//        do {
//            let result = try context.fetch(request)
//            for data in result {
//                print(data.value(forKey: "title") as! String)
//                let item = Item(context: context) <- 新增了一個Item物件在context裡面，saveData時會被存下來
//                item.title = data.value(forKey: "title") as? String
//                item.checked = data.value(forKey: "checked") as! Bool
//                itemArray.append(item)
//            }
//            print(itemArray.count)
//
//        } catch {
//            print("Failed")
//        }
        if request.predicate == nil {
            request.predicate = NSPredicate(format: "toCategory.name MATCHES %@", parentCategory!.name!)
        }
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Fail loading data. Error : \(error)")
        }
    }

    func deleteAllData() {
        for item in itemArray {
            context.delete(item)
        }
        saveData()
        loadData()
    }
}

// MARK: - SearchBar Delegate Methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ AND toCategory.name MATCHES %@", searchBar.text!, parentCategory!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        loadData(with: request)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()

        if searchText != "" {
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@ AND toCategory.name MATCHES %@", searchText, parentCategory!.name!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }

        loadData(with: request)
        tableView.reloadData()
    }
}
