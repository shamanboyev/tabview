//
//  ChecklistItem.swift
//  Checklist2
//
//  Created by Shakhzod Omonbayev on 2/2/20.
//  Copyright © 2020 Shakhzod Omonbayev. All rights reserved.
//

import Foundation
import UserNotifications

class CheckListItem: NSObject, Codable {
    @objc var text: String = ""
    var checked: Bool = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID = -1
    
    func toggleChecked(){
        checked = !checked
    }
    
    init(_ text: String){
        self.text = text
        super.init()
        itemID = DataModel.nextChecklistItemID()
    }
    
    init(_ text: String, _ checked: Bool){
        self.text = text
        self.checked = checked
        super.init()
        itemID = DataModel.nextChecklistItemID()
    }
    
    func scheduleNotification() {
        removeNotification()
        if shouldRemind && dueDate > Date() {
        // 1
        let content = UNMutableNotificationContent()
        content.title = "Reminder:"
        content.body = text
        content.sound = UNNotificationSound.default

        // 2
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(
                              [.year, .month, .day, .hour, .minute],
                              from: dueDate)
        // 3
        let trigger = UNCalendarNotificationTrigger(
                                        dateMatching: components,
                                             repeats: false)
        // 4
        let request = UNNotificationRequest(
                identifier: "\(itemID)", content: content,
                   trigger: trigger)
        // 5
        let center = UNUserNotificationCenter.current()
        center.add(request)

//        print("Scheduled: \(request) for itemID: \(itemID)")
      }
    }
    
    func removeNotification() {
      let center = UNUserNotificationCenter.current()
      center.removePendingNotificationRequests(
                               withIdentifiers: ["\(itemID)"])
    }
    
    
    deinit {
      removeNotification()
    }
}
