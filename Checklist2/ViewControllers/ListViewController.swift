//
//  ListViewController.swift
//  Checklist2
//
//  Created by Shakhzod Omonbayev on 7/3/20.
//  Copyright © 2020 Shakhzod Omonbayev. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    
    var cellIdentifier = "Checklist"
    var dataModel = DataModel()
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title="Checklists"
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.lists.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing{
            return
        }
        dataModel.indexOfSelectedChecklist = indexPath.row
        let todoListok = dataModel.lists[indexPath.row]
        performSegue(withIdentifier: "showChecklist", sender: todoListok)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChecklist"{
            let controller = segue.destination as? ViewController
            controller?.checklist = sender as? ToDoList
        }else if segue.identifier == "addChecklist"{
            let controller = segue.destination as? ListDetailTableViewController
            controller?.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let checklist = dataModel.lists[indexPath.row]
        cell.textLabel?.text = checklist.name
        cell.detailTextLabel?.text = checklist.captionForCount()
        cell.imageView!.image = UIImage.init(named: checklist.imageName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { dataModel.lists.remove(at: indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let controller = storyboard!.instantiateViewController( withIdentifier: "ListDetailTableViewController") as! ListDetailTableViewController
        controller.delegate = self
        
        let checklist = dataModel.lists[indexPath.row]
        controller.toDoListToEdit = checklist
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        if let selectedRows = tableView.indexPathsForSelectedRows{
            for indexPath in selectedRows{
                let rowToDelete = indexPath.row > dataModel.lists.count - 1 ? dataModel.lists.count - 1 : indexPath.row
                let item = dataModel.lists[rowToDelete]
                if let deleteIndex = dataModel.lists.firstIndex(of: item){
                    dataModel.lists.remove(at: deleteIndex)
                }
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
        }
        
        //            deleteButton.isEnabled = false
        //            tableView.setEditing(false, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
        deleteBarButton.isEnabled = !deleteBarButton.isEnabled
        addBarButton.isEnabled = !addBarButton.isEnabled
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        let index = dataModel.indexOfSelectedChecklist
        if index != -1 && index < dataModel.lists.count{
            let savedChecklist = dataModel.lists[index]
            performSegue(withIdentifier: "showChecklist", sender: savedChecklist)
        }
    }
}


extension ListViewController: ListDetailViewControllerDelegate{
    func listDetailViewControllerDidCancel(_ controller: ListDetailTableViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailTableViewController, didFinishAdding checklist: ToDoList) {
        let newRowIndex = dataModel.lists.count
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        dataModel.lists.append(checklist)
        tableView.insertRows(at: [indexPath], with: .automatic)
        dataModel.sortToDoLists()
        navigationController?.popViewController(animated: true)
    }
    
    func listDetailViewController(_ controller: ListDetailTableViewController, didFinishEditing checklist: ToDoList) {
        if let index = dataModel.lists.firstIndex(of: checklist){
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.textLabel!.text = checklist.name
            }
        }
        dataModel.sortToDoLists()
        navigationController?.popViewController(animated: true)
    }
}


extension ListViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Was the back button tapped?

        if viewController === self { dataModel.indexOfSelectedChecklist = -1 }
    }
}
