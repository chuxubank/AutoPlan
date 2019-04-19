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
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var deferDateLabel: UILabel!
    @IBOutlet weak var deferDatePicker: UIDatePicker!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var durationTimePicker: UIDatePicker!
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    @IBAction func deferDatePickerValueChanged(_ sender: UIDatePicker) {
        if(deferDatePicker.date > dueDatePicker.date) {
            dueDatePicker.date = deferDatePicker.date
        }
        updateDateTimeLabel()
    }
    @IBAction func dueDatePickerValueChanged(_ sender: UIDatePicker) {
        if(dueDatePicker.date < deferDatePicker.date) {
            deferDatePicker.date = dueDatePicker.date
        }
        updateDateTimeLabel()
    }
    
    @IBAction func durationTimePickerValueChanged(_ sender: UIDatePicker) {
        updateDateTimeLabel()
    }
    
    let deferDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let dueDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    let durationTimePickerCellIndexPath = IndexPath(row: 5, section: 1)
    
    let notesTextViewIndexPath = IndexPath(row: 1, section: 2)
    
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
    
    var isDurationTimePickerShown: Bool = false {
        didSet {
            durationTimePicker.isHidden = !isDurationTimePickerShown
        }
    }
    
    var durationMinutes: Int {
        return Int(durationTimePicker.countDownDuration/60)
    }
    
    func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }

    func updateDateTimeLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        deferDateLabel.text = dateFormatter.string(from: deferDatePicker.date)
        dueDateLabel.text = dateFormatter.string(from: dueDatePicker.date)
        
        durationTimeLabel.text = String(format:"%d mins", durationMinutes)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load data
        if let task = task {
            titleTextField.text = task.title
            notesTextView.text = task.notes
            deferDatePicker.date = task.deferDate ?? Date()
            dueDatePicker.date = task.dueDate ?? Date()
            durationTimePicker.countDownDuration = TimeInterval(task.duration*60)
        } else {
            durationTimePicker.countDownDuration = 25*60
        }
        
        updateDateTimeLabel()
        updateDoneButtonState()
    }
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)   // Hide Keyboard
        // Switch DatePicker
        switch (indexPath.section, indexPath.row) {
        case (deferDatePickerCellIndexPath.section, deferDatePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = !isDeferDatePickerShown
            isDueDatePickerShown = false
            isDurationTimePickerShown = false
            
        case (dueDatePickerCellIndexPath.section, dueDatePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = false
            isDueDatePickerShown = !isDueDatePickerShown
            isDurationTimePickerShown = false
        
        case (durationTimePickerCellIndexPath.section, durationTimePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = false
            isDueDatePickerShown = false
            isDurationTimePickerShown = !isDurationTimePickerShown
            
        default:
            break
        }
        tableView.beginUpdates()
        tableView.endUpdates()
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
        case (durationTimePickerCellIndexPath.section, durationTimePickerCellIndexPath.row):
            if isDurationTimePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case (notesTextViewIndexPath.section, notesTextViewIndexPath.row):
            return 180.0
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
        task?.notes = notesTextView.text ?? ""
        task?.dueDate = dueDatePicker.date
        task?.deferDate = deferDatePicker.date
        task?.duration = Int16(durationMinutes)
    }

}
