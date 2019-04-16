//
//  TaskTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/2.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class AddEditTaskTableViewController: UITableViewController {
    
    let context = AppDelegate.viewContext
    
    var task: Task? = nil

    @IBOutlet weak var doneBarButton: UIBarButtonItem!
        
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var deferDateLabel: UILabel!
    @IBOutlet weak var deferDatePicker: UIDatePicker!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBAction func deferDatePickerValueChanged(_ sender: UIDatePicker) {
        if(deferDatePicker.date > dueDatePicker.date) {
            dueDatePicker.date = deferDatePicker.date
        }
        updateDateViews()
    }
    
    @IBAction func dueDatePickerValueChanged(_ sender: UIDatePicker) {
        if(dueDatePicker.date < deferDatePicker.date) {
            deferDatePicker.date = dueDatePicker.date
        }
        updateDateViews()
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    let deferDatePickerCellIndexPath = IndexPath(row: 1, section: 2)
    
    let dueDatePickerCellIndexPath = IndexPath(row: 3, section: 2)
    
    var isDeferDatePickerShown: Bool = false {
        didSet {
            deferDatePicker.isHidden = !isDeferDatePickerShown
        }
    }
    
    var isDueDatePickerShown: Bool = false {
        didSet {
            dueDatePicker.isHidden = !isDueDatePickerShown
        }
    }
    
    func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }

    func updateDateViews() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        deferDateLabel.text = dateFormatter.string(from: deferDatePicker.date)
        dueDateLabel.text = dateFormatter.string(from: dueDatePicker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load data
        if let task = task {
            titleTextField.text = task.title
            noteTextView.text = task.notes
            deferDatePicker.date = task.deferDate ?? Date()
            dueDatePicker.date = task.dueDate ?? Date()
        }
        
        updateDateViews()
        updateDoneButtonState()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Switch DatePicker
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (deferDatePickerCellIndexPath.section, deferDatePickerCellIndexPath.row - 1):
            view.endEditing(true)
            if isDeferDatePickerShown {
                isDeferDatePickerShown = false;
            } else if isDueDatePickerShown {
                isDueDatePickerShown = false
                isDeferDatePickerShown = true
            } else {
                isDeferDatePickerShown = true
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case (dueDatePickerCellIndexPath.section, dueDatePickerCellIndexPath.row - 1):
            view.endEditing(true)   // Hide Keyboard
            if isDueDatePickerShown {
                isDueDatePickerShown = false
            } else if isDeferDatePickerShown {
                isDeferDatePickerShown = false
                isDueDatePickerShown = true
            } else {
                isDueDatePickerShown = true
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Define Date Picker height
        switch (indexPath.section, indexPath.row) {
        case (deferDatePickerCellIndexPath.section, deferDatePickerCellIndexPath.row):
            if isDeferDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case (dueDatePickerCellIndexPath.section, dueDatePickerCellIndexPath.row):
            if isDueDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        default:
            return 44.0
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "taskDoneUnwind" else { return }
        
        if task == nil {
            task = Task(context: context)
        }
        
        task!.title = titleTextField.text ?? ""
        task?.notes = noteTextView.text ?? ""
        task?.dueDate = dueDatePicker.date
        task?.deferDate = deferDatePicker.date
        
//        print("title: \(task.title) note: \(task.note)")
//        print("deadline: \(task.deadline)")
    }

}
