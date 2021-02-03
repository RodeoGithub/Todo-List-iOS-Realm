//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Rodrigo Maidana on 23/01/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.tintColor = .black
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let navBarBackgroundColor = UIColor(red: 1.00, green:
        0.83, blue: 0.16, alpha: 1.00)
        configureNavigationBar(largeTitleColor: .black, backgoundColor: navBarBackgroundColor, tintColor: .black, title: K.appName, preferredLargeTitle: false)
    }

    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellId, for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        
        return cell;
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.goToItemsSegue, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if categories == nil {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (deleteAction, view, success:(Bool)->Void) in
            self.deleteCategory(at: indexPath)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            success(true)
        }

        deleteAction.image = UIImage(systemName: K.trashIcon)
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Add new category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: K.AddCategory.alertTitle, message: nil, preferredStyle: .alert)
        
        let action = UIAlertAction(title: K.AddCategory.addButtonTitle, style: .default) { (action) in
            if let categoryName = textField.text {
                let newCategory = Category()
                if categoryName != "" {
                    newCategory.name = categoryName
                }
                else {
                    newCategory.name = K.AddCategory.emptyCategory
                }
                self.save(category: newCategory)
                self.tableView.reloadData()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            return
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = K.AddCategory.alertTextPlaceholder
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    // MARK: - Database
    
    func loadCategories() {
        categories = realm.objects(Category.self)
    }
    
    func save(category: Category) {
        do{
            try realm.write {
                realm.add(category)
            }
        }
        catch {
            print("\(error)")
        }
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        do {
            try realm.write {
                if let categoryForDeletion = categories?[indexPath.row]{
                    realm.delete(categoryForDeletion)
                }
            }
        }
        catch {
            print("Error deleting category \(error)")
        }
    }
}

// MARK: - Navigation Bar Configuration

extension UIViewController {
    func configureNavigationBar(largeTitleColor: UIColor, backgoundColor: UIColor, tintColor: UIColor, title: String, preferredLargeTitle: Bool) {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.titleTextAttributes = [.foregroundColor: largeTitleColor]
            navBarAppearance.backgroundColor = backgoundColor
            
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            
            navigationController?.navigationBar.prefersLargeTitles = preferredLargeTitle
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = tintColor
            navigationItem.title = title
        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.barTintColor = backgoundColor
            navigationController?.navigationBar.tintColor = tintColor
            navigationController?.navigationBar.isTranslucent = false
            navigationItem.title = title
        }
    }
}
