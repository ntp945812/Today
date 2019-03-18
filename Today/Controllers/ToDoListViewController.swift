//
//  ViewController.swift
//  Today
//
//  Created by 謝冠緯 on 2019/3/17.
//  Copyright © 2019年 謝冠緯. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    let defults = UserDefaults.standard

    var itemArray = [Item]()

    let filepath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("items.plist")

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

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
                let item = Item(toDoListTitle: alert.textFields!.first!.text!, isChecked: false)
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

    // MARK: - Manage Data Methods

    func saveData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: filepath!)
        } catch {
            print("Fail Saving data. Error : \(error)")
        }
    }

    func loadData() {
        let decoder = PropertyListDecoder()
        do {
            itemArray = try decoder.decode([Item].self, from: Data(contentsOf: filepath!))
        } catch {
            print("Fail loading data. Error : \(error)")
        }
    }
}
