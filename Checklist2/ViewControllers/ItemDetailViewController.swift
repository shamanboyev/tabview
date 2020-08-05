//
//  SecondTableViewController.swift
//  Checklist2
//
//  Created by Shakhzod Omonbayev on 2/2/20.
//  Copyright © 2020 Shakhzod Omonbayev. All rights reserved.
//

import UIKit

class ItemDetailViewController: UITableViewController {
    
    // MARK:- Variable Declaration
    var chosenPriority : ToDoList.Priority?
    var dueDate = Date()
    var priorityButtonsHidden: Bool = true
    weak var toDoList: ToDoList?
    weak var itemToEdit: CheckListItem?
    weak var delegate: ItemDetailViewDelegate?
    
    @IBOutlet var priorityButtons: [UIButton]!
    @IBOutlet weak var selectedPriority: UIButton!
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    // MARK:- Button functions
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        dueDate = sender.date
        updateDueDateLabel()
    }
    @IBAction func cancelButton(_ sender: Any) {
        delegate?.ItemDetailViewController(self)
    }
    
    @IBAction func doneButton(_ sender: Any) {
        if let priority = chosenPriority{
            if let item = itemToEdit,
                let text = textField.text{
                item.text = text
                item.shouldRemind = shouldRemindSwitch.isOn
                item.dueDate = dueDate
                item.scheduleNotification()
                delegate?.ItemDetailViewController(self, didFinishEditing: item, priority: priority)
            } else
                if let item = toDoList?.createNewItem(){
                    if let textFieldText = textField.text {
                        item.text = textFieldText
                        item.checked = false
                        item.shouldRemind = shouldRemindSwitch.isOn
                        item.dueDate = dueDate
                        item.scheduleNotification()
                        delegate?.ItemDetailViewController(self, didFinishAdding: item, priority: priority)
                    }
            }
        }else{
            let alert = UIAlertController(title: "Incomplete Form", message: "Please choose a priority", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    @IBAction func handleSelection(_ sender: UIButton) {
        toggleButtons()
        textField.resignFirstResponder()
        if !datePicker.isHidden{ hideDatePicker() }
    }
    
    @IBAction func priorityTapped(_ sender: UIButton) {
        if let title = sender.currentTitle,
            let priority = toDoList?.priorityForString(title){
            chosenPriority = priority
            let newTitle = toDoList?.stringForPriority(chosenPriority!)
            toggleButtons()
            selectedPriority.titleLabel?.adjustsFontSizeToFitWidth = true
            selectedPriority.setTitle(newTitle, for: .normal)
        }
    }
    // MARK:- Secondary functions triggered by buttons
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateLabel.text = formatter.string(from: dueDate)
    }
    
    func toggleButtons(){
        priorityButtons.forEach{ (button) in
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
        priorityButtonsHidden = !priorityButtonsHidden
    }
    
    func showDatePicker() {
        if !priorityButtonsHidden{
            toggleButtons()
        }
      datePicker.isHidden = false
      let indexPathDatePicker = IndexPath(row: 2, section: 1)
      tableView.insertRows(at: [indexPathDatePicker], with: .fade)
      datePicker.setDate(dueDate, animated: false)
      dueDateLabel.textColor = dueDateLabel.tintColor
    }
    
    func hideDatePicker() {
        if !datePicker.isHidden {
            datePicker.isHidden = true
        let indexPathDatePicker = IndexPath(row: 2, section: 1)
        tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
        dueDateLabel.textColor = UIColor.black
      }
    }
    
    @IBAction func shouldRemindToggled(_ switchControl: UISwitch) {
      textField.resignFirstResponder()

      if switchControl.isOn {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {
          granted, error in
          // do nothing
        }
      }
    }
    // MARK:- Table View Built-in Functions
    
   override func tableView(_ tableView: UITableView,
              willSelectRowAt indexPath: IndexPath) -> IndexPath? {
      if indexPath.section == 1 && indexPath.row == 1 {
        return indexPath
      } else {
        return nil
      }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 2 { return datePickerCell}
        else { return super.tableView(tableView, cellForRowAt: indexPath) }
    }
    
    override func tableView(_ tableView: UITableView,
          numberOfRowsInSection section: Int) -> Int {
        if section == 1 && !datePicker.isHidden {
        return 3
      } else {
        return super.tableView(tableView,
          numberOfRowsInSection: section)
      }
    }
    
    override func tableView(_ tableView: UITableView,
               heightForRowAt indexPath: IndexPath) -> CGFloat {
      if indexPath.section == 1 && indexPath.row == 2 {
        return 217
      } else {
        return super.tableView(tableView, heightForRowAt: indexPath)
      }
    }
    
    override func tableView(_ tableView: UITableView,
               didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      textField.resignFirstResponder()
      if indexPath.section == 1 && indexPath.row == 1 {
        if datePicker.isHidden {
          showDatePicker()
        } else {
          hideDatePicker()
        }
      }
    }
    
    override func tableView(_ tableView: UITableView,
      indentationLevelForRowAt indexPath: IndexPath) -> Int {
      var newIndexPath = indexPath
      if indexPath.section == 1 && indexPath.row == 2 {
        newIndexPath = IndexPath(row: 0, section: indexPath.section)
      }
      return super.tableView(tableView,
              indentationLevelForRowAt: newIndexPath)
    }
    
    // MARK:- View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.delegate = self
        textField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let item = itemToEdit,
            let priority = chosenPriority{
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.isEnabled = true
            selectedPriority.titleLabel?.adjustsFontSizeToFitWidth = true
            let priora = toDoList!.stringForPriority(priority)
            selectedPriority.setTitle(priora, for: .normal)
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.dueDate
        } else{
            title = "Add Item"
        }
        
        datePicker.isHidden = true
        updateDueDateLabel()
        navigationItem.largeTitleDisplayMode = .never
    }
}

// MARK:- Extensions and Protocols
extension ItemDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
            let stringRange = Range(range, in: oldText) else {
                return false
        }
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        doneBarButton.isEnabled = !newText.isEmpty
        selectedPriority.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
      hideDatePicker()
    }
}

protocol ItemDetailViewDelegate: class {
    func ItemDetailViewController(_ controller: ItemDetailViewController)
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishAdding item: CheckListItem, priority: ToDoList.Priority)
    func ItemDetailViewController(_ controller: ItemDetailViewController, didFinishEditing item: CheckListItem, priority: ToDoList.Priority)
}
