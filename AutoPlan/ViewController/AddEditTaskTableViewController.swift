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
    var currentProject: Project? = nil
    var prerequisiteTasks = [Task]()
    var dependentsTasks = [Task]()
    let deferDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let dueDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    let durationTimePickerCellIndexPath = IndexPath(row: 5, section: 1)
    let projectCellIndexPath = IndexPath(row: 0, section: 2)
    let notesTextViewIndexPath = IndexPath(row: 0, section: 3)
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
    var isProjectSelected: Bool {
        return currentProject != nil
    }
    
    // MARK: - IB
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var deferDateLabel: UILabel!
    @IBOutlet weak var deferDatePicker: UIDatePicker!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var durationTimeLabel: UILabel!
    @IBOutlet weak var durationTimePicker: UIDatePicker!
    @IBOutlet weak var projectLabel: UILabel!
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    @IBAction func deferDatePickerValueChanged(_ sender: UIDatePicker) {
        if(deferDatePicker.date > dueDatePicker.date) {
            dueDatePicker.date = deferDatePicker.date
        }
        updateDateLabel()
    }
    @IBAction func dueDatePickerValueChanged(_ sender: UIDatePicker) {
        if(dueDatePicker.date < deferDatePicker.date) {
            deferDatePicker.date = dueDatePicker.date
        }
        updateDateLabel()
    }
    @IBAction func durationTimePickerValueChanged(_ sender: UIDatePicker) {
        updateTimeLabel()
    }
    
    // MARK: - View Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load data
        if let task = task {
            titleTextField.text = task.title
            notesTextView.text = task.notes
            deferDatePicker.date = task.deferDate ?? Date()
            dueDatePicker.date = task.dueDate ?? Date()
            durationTimePicker.countDownDuration = TimeInterval(task.duration*60)
            
            currentProject = task.project
            prerequisiteTasks = task.prerequisites?.allObjects as! [Task]
            dependentsTasks = task.dependents?.allObjects as! [Task]
        } else {
            durationTimePicker.countDownDuration = 25*60
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    func updateUI() {
        updateDoneButtonState()
        updateDateLabel()
        updateTimeLabel()
        updateProjectLabel()
    }
    
    func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }
    
    func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        deferDateLabel.text = dateFormatter.string(from: deferDatePicker.date)
        dueDateLabel.text = dateFormatter.string(from: dueDatePicker.date)
    }
    
    func updateTimeLabel() {
        durationTimeLabel.text = String(format:"%d mins", durationMinutes)
    }
    
    func updateProjectLabel() {
        projectLabel.text = isProjectSelected ? currentProject?.title : "None"
    }
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)   // Hide Keyboard
        // Toggle DatePicker
        switch (indexPath.section, indexPath.row) {
        case (deferDatePickerCellIndexPath.section, deferDatePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = !isDeferDatePickerShown
            isDueDatePickerShown = false
            isDurationTimePickerShown = false
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case (dueDatePickerCellIndexPath.section, dueDatePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = false
            isDueDatePickerShown = !isDueDatePickerShown
            isDurationTimePickerShown = false
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case (durationTimePickerCellIndexPath.section, durationTimePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = false
            isDueDatePickerShown = false
            isDurationTimePickerShown = !isDurationTimePickerShown
            tableView.beginUpdates()
            tableView.endUpdates()
        
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Define Date Picker height
        switch (indexPath) {
        case (deferDatePickerCellIndexPath):
            return isDeferDatePickerShown ? 216.0 : 0.0
        
        case (dueDatePickerCellIndexPath):
            return isDueDatePickerShown ? 216.0 : 0.0
        
        case (durationTimePickerCellIndexPath):
            return isDurationTimePickerShown ? 216.0 : 0.0
        
        case [projectCellIndexPath.section, projectCellIndexPath.row + 1],
             [projectCellIndexPath.section, projectCellIndexPath.row + 2]:
            return isProjectSelected ? 44.0 : 0.0
            
        case (notesTextViewIndexPath):
            return 180.0
        
        default:
            return 44.0
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case "taskDoneUnwind":
            if task == nil {
                task = Task(context: context)
            }
            task!.title = titleTextField.text ?? ""
            task?.notes = notesTextView.text ?? ""
            task?.dueDate = dueDatePicker.date
            task?.deferDate = deferDatePicker.date
            task?.duration = Int16(durationMinutes)
            task?.project = currentProject
        case "SelectProject":
            let selectProjectViewController = segue.destination as! SelectProjectTableViewController
            selectProjectViewController.selectedProject = currentProject
        case "SelectDependentTasks":
            let selectTaskViewController = segue.destination as! SelectTaskTableViewController
            selectTaskViewController.sourceProject = currentProject
            selectTaskViewController.selectedTasks = dependentsTasks
            selectTaskViewController.identifier = "SelectDependentTasks"
        case "SelectPrerequisiteTasks":
            let selectTaskViewController = segue.destination as! SelectTaskTableViewController
            selectTaskViewController.sourceProject = currentProject
            selectTaskViewController.selectedTasks = prerequisiteTasks
            selectTaskViewController.identifier = "SelectPrerequisiteTasks"
        default:
            break
        }
    }

    @IBAction func unwindToTask(segue: UIStoryboardSegue) {
        
    }
}
