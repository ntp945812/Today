//
//  ViewController.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/17.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import RealmSwift
import UIKit

class ToDoListViewController: UITableViewController {
    lazy var realm = try! Realm()

    @IBOutlet var toDoItemSearchBar: UISearchBar!

    var itemArray: Results<Item>?
    var parentCategory: Category? {
        didSet {
            itemArray = parentCategory?.items.sorted(byKeyPath: "createdDate", ascending: false)
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func tableViewTapped(){
        toDoItemSearchBar.resignFirstResponder()
    }

    // MARK: - Tableview Datasource Methods

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray![indexPath.row].title
        cell.accessoryType = itemArray![indexPath.row].checked == false ? .none : .checkmark
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray!.count
    }

    // MARK: - Tableview Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        do {
            try realm.write {
                itemArray![indexPath.row].checked = !itemArray![indexPath.row].checked
            }
        } catch {
            print("Fail to change property checked. Error :\(error)")
        }

        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = itemArray![indexPath.row].checked == false ? .none : .checkmark
        cell?.tintColor = UIColor.black

        tableView.reloadData()
    }

    // MARK: - Add New Items

    @IBAction func addItemButtomPushed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add a todo to the list", message: "", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Cteate New Item"
        }

        let action = UIAlertAction(title: "Add ", style: .default) { _ in
            if alert.textFields?.first?.text != "" {
                let newItem = Item()
                newItem.title = alert.textFields!.first!.text!
                newItem.createdDate = Date()

                do {
                    try self.realm.write {
                        self.parentCategory!.items.append(newItem)
                    }
                } catch {
                    print("Error append item to itemArray. Error :\(error)")
                }

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
            self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    // MARK: - Manage Data Methods

//    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
    ////        let request = NSFetchRequest<NSManagedObject>(entityName: "Item")
    ////
    ////        do {
    ////            let result = try context.fetch(request)
    ////            for data in result {
    ////                print(data.value(forKey: "title") as! String)
    ////                let item = Item(context: context) <- 新增了一個Item物件在context裡面，saveData時會被存下來
    ////                item.title = data.value(forKey: "title") as? String
    ////                item.checked = data.value(forKey: "checked") as! Bool
    ////                itemArray.append(item)
    ////            }
    ////            print(itemArray.count)
    ////
    ////        } catch {
    ////            print("Failed")
    ////        }
//        if request.predicate == nil {
//            request.predicate = NSPredicate(format: "toCategory.name MATCHES %@", parentCategory!.name!)
//        }
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Fail loading data. Error : \(error)")
//        }
//    }

    func deleteAllData() {
        try! realm.write {
            for item in itemArray! {
                realm.delete(item)
            }
        }
    }
}

// MARK: - SearchBar Delegate Methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "createdDate", ascending: false)

        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            itemArray = parentCategory?.items.filter(NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
        } else {
            searchBar.resignFirstResponder()
            itemArray = parentCategory?.items.sorted(byKeyPath: "createdDate", ascending: false)
        }

        tableView.reloadData()
    }
}
