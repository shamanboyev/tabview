//
//  DataModel.swift
//  Checklist2
//
//  Created by Shakhzod Omonbayev on 7/6/20.
//  Copyright © 2020 Shakhzod Omonbayev. All rights reserved.
//

import Foundation


class DataModel {
    var lists = [ToDoList]()
    
    var indexOfSelectedChecklist: Int {
        get {
            return UserDefaults.standard.integer( forKey: "ChecklistIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ChecklistIndex")
        }
    }
    
    init() {
        loadToDoLists()
        registerDefaults()
        handleFirstTime()
    }
    
    // MARK:- Data Saving
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func dataFilePath() -> URL { return documentsDirectory().appendingPathComponent( "Checklists.plist") }
    
    // this method is now called saveChecklists()
    func saveToDoLists() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(lists)
            try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic) } catch {
                print("Error encoding list array: \(error.localizedDescription)") }
    }
    
    // this method is now called loadChecklists()
    func loadToDoLists() {
        let path = dataFilePath()
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do { // You decode to an object of [Checklist] type to lists
                lists = try decoder.decode([ToDoList].self, from: data)
            } catch {
                print("Error decoding list array: \(error.localizedDescription)")
            }
        }
        sortToDoLists()
    }
    
    func registerDefaults() {
        let dictionary = [ "ChecklistIndex": -1, "FirstTime": true ] as [String : Any]
        UserDefaults.standard.register(defaults: dictionary)
    }
    
    func handleFirstTime() {
        
        let userDefaults = UserDefaults.standard
        let firstTime = userDefaults.bool(forKey: "FirstTime")
        if firstTime {
            let firstToDo = ToDoList(name: "List")
            lists.append(firstToDo)
            indexOfSelectedChecklist = 0
            userDefaults.set(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    func sortToDoLists() {
        lists.sort(by: { list1, list2 in
        return list1.name.localizedStandardCompare(list2.name)
                      == .orderedAscending })
    }
    
    class func nextChecklistItemID() -> Int {
      let userDefaults = UserDefaults.standard
      let itemID = userDefaults.integer(forKey: "ChecklistItemID")
      userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
      userDefaults.synchronize()
      return itemID
    }

    
}
