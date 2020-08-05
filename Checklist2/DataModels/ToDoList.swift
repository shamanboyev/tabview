//
//  ToDoList.swift
//  Checklist2
//
//  Created by Shakhzod Omonbayev on 2/2/20.
//  Copyright © 2020 Shakhzod Omonbayev. All rights reserved.
//

import Foundation

class ToDoList: NSObject, Codable {
    
    var name: String = ""
    var highPriorityList = [CheckListItem]()
    var mediumPriorityList = [CheckListItem]()
    var lowPriorityList = [CheckListItem]()
    var noPriorityList = [CheckListItem]()
    var imageName: String
    init(name: String, icon: String = "No Icon") {
        self.name = name
        self.imageName = icon
        super.init()
    }
    
    enum Priority: Int, CaseIterable {
        case high,medium,low,no
    }
    
    func listforPriority( _ priority: Priority) -> [CheckListItem]{
        switch priority {
        case .high :
            return highPriorityList
        case .medium :
            return mediumPriorityList
        case .low :
            return lowPriorityList
        case .no :
            return noPriorityList
        }
    }
    
    func stringForPriority(_ priora: ToDoList.Priority) -> String {
        switch priora{
        case .high:
            return "High Priority"
        case .medium:
            return "Medium Priority"
        case .low:
            return "Low Priority"
        case .no:
            return "No Priority"
        }
    }
    
    func priorityForString(_ stringetto: String) -> ToDoList.Priority? {
        var chosenPriority: ToDoList.Priority?
        switch stringetto{
            case "High":
                chosenPriority = .high
            case "Medium":
                chosenPriority = .medium
            case "Low":
                chosenPriority = .low
            case "No":
                chosenPriority = .no
        default:
                chosenPriority = nil
            }
        return chosenPriority

    }
    
    func addItemToList(to priority: Priority = .medium, _ item : CheckListItem, at index: Int = -1){
        switch priority {
        case .high :
            if index < 0
            {highPriorityList.append(item)}else{ highPriorityList.insert(item, at: index)}
        case .medium :
            if index < 0 {mediumPriorityList.append(item)}else{ mediumPriorityList.insert(item, at: index)}
        case .low :
            if index < 0 {lowPriorityList.append(item)}else{ lowPriorityList.insert(item, at: index)}
        case .no :
            if index < 0 {noPriorityList.append(item)}else{ noPriorityList.insert(item, at: index)}
        }
    }
    func move(item: CheckListItem, from sourcePriority: Priority, at sourceIndex: Int,
              to destinationPriority: Priority, at destinationIndex: Int) {
        removeItemfromList(from: sourcePriority, item: item, at: sourceIndex)
        addItemToList(to: destinationPriority, item, at: destinationIndex)
    }
    func removeItemfromList(from priority: Priority, item: CheckListItem, at index: Int){
        switch priority {
        case .high :
            highPriorityList.remove(at: index)
        case .medium :
            mediumPriorityList.remove(at: index)
        case .low :
            lowPriorityList.remove(at: index)
        case .no :
            noPriorityList.remove(at: index)
        }
    }
    func createNewItem() -> CheckListItem {
        let item = CheckListItem("New To Do")
        item.checked = false
        return item
    }
    
    func countUncheckedItems() -> (Int,Int) {
        var uncheckedCount = 0
        var totalCount = 0
        for priority in Priority.allCases{
            let list = listforPriority(priority)
            for item in list{
                totalCount += 1
                if !item.checked{
                    uncheckedCount += 1
                }
            }
        }
        
        return (totalCount, uncheckedCount)
    }
    
    func captionForCount() -> String {
        let (numOfItems, numofUncheckedItems) = self.countUncheckedItems()
        let cellCaption: String
        if numOfItems == 0 {
             cellCaption = "(No items)"
        }else{
        cellCaption = numofUncheckedItems == 0 ? "All done" : "\(numofUncheckedItems) Remaining"
        }
        return cellCaption
    }
}
