//
//  ViewController.swift
//  CoreDataToDoList
//
//  Created by 林祔利 on 2023/9/19.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let tableview : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    
    private var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItem()
        title = "CoreData To Do List"
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item",
                                      message: "Enter New Item",
                                      preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default,handler: { _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self.createItem(name: text)
        }))
        present(alert, animated: true)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default,handler: { _ in
            let alert = UIAlertController(title: "Edit",
                                          message: "Edit your name",
                                          preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                
                guard let field = sheet.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                
                self?.updateItem(item: item, newName: newName)
            }))

            self.present(alert, animated: true)
            
            
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .default,handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }
    
    
    
    
    //Core Date
    func getAllItem() {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
            
        } catch  {
            //error
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createAt = Date()
        do{
            try context.save()
            getAllItem()
        }catch {
            //error
        }
        
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do{
            try context.save()
            getAllItem()
        }catch {
            //error
        }
    }
    
    func updateItem(item: ToDoListItem,newName: String) {
        item.name = newName
        
        do{
            try context.save()
            getAllItem()
        }catch {
            //error
        }
    }
    
}

