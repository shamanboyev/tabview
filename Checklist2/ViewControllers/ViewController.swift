//
//  ViewController.swift
//  Checklist2
//
//  Created by Shakhzod Omonbayev on 2/2/20.
//  Copyright © 2020 Shakhzod Omonbayev. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var addBarButton: UIBarButtonItem!
    var checklist: ToDoList!
    
    func getPriority(_ index: Int) -> ToDoList.Priority? {//returning Int representation of each priority: used for sections
        return ToDoList.Priority(rawValue: index)
    }
    
    required init?(coder acoder: NSCoder) {//init required to define a todolist, which will be filled during loadChecklistItems
        super.init(coder: acoder)
    }
    
    //invokes when delete button is pressed after selecting several rows, firstly acquires the indexpathes for all selected items
    //then gets priority and todochecklists using row/section, after that checks for index out of bounds and deletes items
    //one by one from the model, after the for loop it updates the view synchronizing it with the model.
    @IBAction func deleteBarButton(_ sender: UIBarButtonItem) {
        if let selectedRows = tableView.indexPathsForSelectedRows{
            for indexPath in selectedRows{
                if let priority = getPriority(indexPath.section){
                    let todos = checklist.listforPriority(priority)
                    let rowToDelete = indexPath.row > todos.count - 1 ? todos.count - 1 : indexPath.row
                    let item = todos[rowToDelete]
                    checklist.removeItemfromList(from: priority, item: item, at: indexPath.row)
                }
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: selectedRows, with: .automatic)
            tableView.endUpdates()
            //            deleteButton.isEnabled = false
//            tableView.setEditing(false, animated: true)
        }
    }
    
    override func viewDidLoad() {//full configure - first step
        deleteButton.isEnabled = false
        navigationItem.largeTitleDisplayMode = .never   
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.allowsMultipleSelectionDuringEditing = true
        title = checklist.name
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.topItem?.title = ""
        super.viewDidLoad()
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(tableView.isEditing, animated: true)
        deleteButton.isEnabled = !deleteButton.isEnabled
        addBarButton.isEnabled = !addBarButton.isEnabled
    }
    
    //displays checkmark and text for a given cell, using indexpath row and section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem",for: indexPath)
        
        if let priority = getPriority(indexPath.section) {
            let item = checklist.listforPriority(priority)[indexPath.row]
            configureText(for: cell, with: item)
            configureCheckmark(for: cell, with: item)
        }
        return cell
        
    }
    
    //deleting a single row using a swipe
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let priority = getPriority(indexPath.section){
            let item = checklist.listforPriority(priority)[indexPath.row]
            checklist.removeItemfromList(from: priority, item: item, at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //^moves the item using the source and destination indexpath row and section, calls corresponding method in model
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let srcPriority = getPriority(sourceIndexPath.section){
            if let destPriority = getPriority(destinationIndexPath.section){
                let item = checklist.listforPriority(srcPriority)[sourceIndexPath.row]
                checklist.move(item: item, from: srcPriority, at: sourceIndexPath.row, to: destPriority, at: destinationIndexPath.row)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {//returning the number of rows in each section according to the number of items in every checklist list.
        if let priority = getPriority(section){
            return checklist.listforPriority(priority).count
        }
        return 0
    }
    override func numberOfSections(in tableView: UITableView) -> Int {//returning number of sections according to the number of priorities
        return ToDoList.Priority.allCases.count
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {//handling the selection of a row - configuring checkmark
        if tableView.isEditing{
            return
        }
        if let cell = tableView.cellForRow(at: indexPath){
            if let priority = getPriority(indexPath.section){
                let item = checklist.listforPriority(priority)[indexPath.row]
                item.toggleChecked()
                configureCheckmark(for: cell, with: item)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let priority = getPriority(section){ return checklist.stringForPriority(priority) }
        else{ return nil }
    }
    
    func configureText(for cell: UITableViewCell, with item: CheckListItem) {//configures text for cell
        if let textCell = cell as? ChecklistTableViewCell{
//            textCell.toDooTextLabel.text = item.text
            textCell.toDooTextLabel.text = item.text
        }
    }
    func configureCheckmark(for cell: UITableViewCell, with item: CheckListItem){//configures checkmark for cell
        if let checkmarkCell = cell as? ChecklistTableViewCell{
            if !item.checked {
                checkmarkCell.checkmarkLabel.text = ""
            } else{
                checkmarkCell.checkmarkLabel.text = "√"
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {//sends a list of checklists or a single checklist
        //depending on the type of segue used. also, becomes a delegate for the forwarded screen.
        if segue.identifier == "AddItemSegue"{
            if let ItemViewController = segue.destination as? ItemDetailViewController{
                ItemViewController.delegate = self
                ItemViewController.toDoList = checklist
            }
        }else if segue.identifier == "EditItemSegue"{
            if let ItemViewController = segue.destination as? ItemDetailViewController{
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let priority = getPriority(indexPath.section){
                    let item = checklist.listforPriority(priority)[indexPath.row]
                    ItemViewController.itemToEdit = item
                    ItemViewController.delegate = self
                    ItemViewController.chosenPriority = priority
                    ItemViewController.toDoList = checklist
                }
            }
        }
    }
}

extension ViewController: ItemDetailViewDelegate {
    func ItemDetailViewController(_ controller: ItemDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: CheckListItem, priority: ToDoList.Priority) {
        navigationController?.popViewController(animated: true)
        let listToAdd = checklist.listforPriority(priority)
        let newRowIndex = listToAdd.count
        checklist.addItemToList(to: priority, item)
        let indexPath = IndexPath(row: newRowIndex, section: priority.rawValue)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: CheckListItem, priority: ToDoList.Priority) {
        
        let priorityList = checklist.listforPriority(priority)
        let newIndex = priorityList.count
        
        for prioritito in ToDoList.Priority.allCases {
            let priorititoList = checklist.listforPriority(prioritito)
            if let index = priorititoList.firstIndex(of: item){
                let delIndexPath = IndexPath(row: index, section: prioritito.rawValue)
                let addIndexPath = IndexPath(row: newIndex, section: priority.rawValue)
                
                if priority == prioritito{
                    tableView.reloadRows(at: [delIndexPath], with: .automatic)
                }else{
                checklist.removeItemfromList(from: prioritito, item: item, at: index)
                checklist.addItemToList(to: priority, item)
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [delIndexPath], with: .automatic)
                tableView.insertRows(at: [addIndexPath], with: .automatic)
                tableView.endUpdates()
                }
//                tableView.update
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
