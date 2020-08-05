//
//  ListDetailTableViewController.swift
//  Checklist2
//
//  Created by Shakhzod Omonbayev on 7/5/20.
//  Copyright © 2020 Shakhzod Omonbayev. All rights reserved.
//

import UIKit

class ListDetailTableViewController: UITableViewController {
    
    var iconName = "Folder"
    var toDoListToEdit: ToDoList?
    weak var delegate: ListDetailViewControllerDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBAction func cancelBarButton(_ sender: UIBarButtonItem) {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    @IBAction func doneBarButtonPressed(_ sender: Any) {
        if let item = toDoListToEdit{
            item.name = textField.text!
            item.imageName = iconName
            delegate?.listDetailViewController(self, didFinishEditing:  item)
        }else{
            let checklist = ToDoList(name: textField.text!, icon: iconName)
            delegate?.listDetailViewController(self, didFinishAdding: checklist)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 1 ? indexPath : nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let itemtoEdit = toDoListToEdit{
            title = "Edit Checklist"
            textField.text = itemtoEdit.name
            iconName = itemtoEdit.imageName
            doneBarButton.isEnabled = true
            iconImage.image = UIImage(named: iconName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
        if let _ = toDoListToEdit{
        title = "Edit Checklist"
        }else{
        title = "Add Checklist"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                             sender: Any?) {
      if segue.identifier == "PickIcon" {
        let controller = segue.destination
                         as! IconPickerViewController
        controller.delegate = self
      }
    }
}


protocol ListDetailViewControllerDelegate: class {
    
func listDetailViewControllerDidCancel( _ controller: ListDetailTableViewController)

func listDetailViewController(_ controller: ListDetailTableViewController, didFinishAdding checklist: ToDoList)

func listDetailViewController(_ controller: ListDetailTableViewController, didFinishEditing checklist: ToDoList)

}

extension ListDetailTableViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        
        doneBarButton.isEnabled = !newText.isEmpty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        doneBarButton.isEnabled = false
        return true
    }
}

extension ListDetailTableViewController: IconPickerViewControllerDelegate {
    func iconPicker(_ picker: IconPickerViewController, didPick iconName: String) {
        self.iconName = iconName
        iconImage.image = UIImage(named: iconName)
        navigationController?.popViewController(animated: true)
    }
}
