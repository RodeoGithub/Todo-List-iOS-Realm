//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    var items: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        addButton.tintColor = .black
        let navBarBackgroundColor = UIColor(red: 1.00, green:
        0.83, blue: 0.16, alpha: 1.00)
        let navBarTitle = selectedCategory?.name ?? K.appName
        configureNavigationBar(largeTitleColor: .black, backgoundColor: navBarBackgroundColor, tintColor: .black, title: navBarTitle, preferredLargeTitle: true)
    }
    
    //MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.itemCellId, for: indexPath)
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items yet"
        }
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            }
            catch {
                print("error checking item \(error)")
            }
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (deleteAction, view, success:(Bool)->Void) in
            self.deleteItem(at: indexPath)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            success(true)
        }

        deleteAction.image = UIImage(systemName: K.trashIcon)
        deleteAction.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
    //MARK: - Add Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: K.AddItem.alertTitle, message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: K.AddItem.addButtonTitle, style: .default) { (action) in
            
            let newItem = Item()

            if textField.text != nil && textField.text != "" {
                newItem.title = textField.text!
            }
            else {
                newItem.title = K.AddItem.emptyItem
            }
            
            newItem.done = false
            newItem.dateCreated = Date()
            self.save(item: newItem)
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = K.AddItem.alertTextPlaceholder
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Database
    
    func loadItems(){
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    }
    
    func save(item: Item){
        do {
            try realm.write {
                selectedCategory?.items.append(item)
                realm.add(item)
            }
        }
        catch {
            print("Error saving data \(error)")
        }
    }
    
    func deleteItem(at indexPath: IndexPath){
        do {
            try realm.write {
                if let item = items?[indexPath.row] {
                    realm.delete(item)
                }
            }
        }
        catch {
            print("Error deleting item \(error)")
        }
    }
}

//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == nil || searchBar.text == "" {
            loadItems()
            tableView.reloadData()
        }
        else {
            items = items?.filter("title CONTAINS[cd] %@", searchBar.text!) ?? items
            tableView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
