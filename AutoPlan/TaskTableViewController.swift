//
//  TaskTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/2.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {

        
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    @IBOutlet weak var deadlineDateLabel: UILabel!
    @IBOutlet weak var deadlineDatePicker: UIDatePicker!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    let context = AppDelegate.viewContext
    
    var task: Task? = nil
    
    let deadlineDatePickerCellIndexPath = IndexPath(row: 1, section: 2)
    
    var isDeadlineDatePickerShown: Bool = false {
        didSet {
            deadlineDatePicker.isHidden = !isDeadlineDatePickerShown
        }
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    
    func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }

    func updateDateViews() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        deadlineDateLabel.text = dateFormatter.string(from: deadlineDatePicker.date)
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = task {
            titleTextField.text = task.title
            noteTextField.text = task.note
            deadlineDatePicker.date = task.deadline ?? Date()
        }
        
        updateDateViews()
        updateDoneButtonState()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (deadlineDatePickerCellIndexPath.section, deadlineDatePickerCellIndexPath.row - 1):
            isDeadlineDatePickerShown = !isDeadlineDatePickerShown
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (deadlineDatePickerCellIndexPath.section, deadlineDatePickerCellIndexPath.row):
            if isDeadlineDatePickerShown {
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
        task?.note = noteTextField.text ?? ""
        task?.deadline = deadlineDatePicker.date
        
//        print("title: \(task.title) note: \(task.note)")
//        print("deadline: \(task.deadline)")
    }

}
