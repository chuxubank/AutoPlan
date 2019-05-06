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
    let costTimePickerCellIndexPath = IndexPath(row: 5, section: 1)
    let splitUnitCellIndexPath = IndexPath(row: 8, section: 1)
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
            costTimePicker.isHidden = !isDurationTimePickerShown
        }
    }
    var costMinutes: Int {
        return Int(costTimePicker.countDownDuration/60)
    }
    var isSplitEnable: Bool {
        return splitCountStepper.value != 1
    }
    var isProjectSelected: Bool {
        return currentProject != nil
    }
    var energyLevel = 3 {
        didSet {
            energyLevelLabel.text = "\(energyLevel)"
        }
    }
    
    // MARK: - IB
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var deferDateLabel: UILabel!
    @IBOutlet weak var deferDatePicker: UIDatePicker!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var costTimeTitleLabel: UILabel!
    @IBOutlet weak var costTimeLabel: UILabel!
    @IBOutlet weak var costTimePicker: UIDatePicker!
    @IBOutlet weak var energyLevelLabel: UILabel!
    @IBOutlet weak var energyLevelStepper: UIStepper!
    @IBAction func energyLevelStepperValueChanged(_ sender: UIStepper) {
        energyLevel = Int(energyLevelStepper.value)
    }
    @IBOutlet weak var splitCountTextField: UITextField!
    @IBOutlet weak var splitCountStepper: UIStepper!
    @IBOutlet weak var splitUnitTextField: UITextField!
    @IBOutlet weak var projectLabel: UILabel!
    @IBOutlet weak var prerequisitesLabel: UILabel!
    @IBOutlet weak var dependentsLabel: UILabel!
    @IBAction func titleTextFieldEditingChanged(_ sender: UITextField) {
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
    @IBAction func splitCountTextFieldEditingChanged(_ sender: Any) {
        splitCountStepper.value = Double(splitCountTextField.text!) ?? 1
    }
    @IBAction func splitCountTextFieldEditingDidEnd(_ sender: UITextField) {
        updateSplitCountTexts()
    }
    @IBAction func splitCountStepperValueChanged(_ sender: UIStepper) {
        updateSplitCountTexts()
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
            costTimePicker.countDownDuration = TimeInterval(task.costMinutes*60)
            currentProject = task.project
            prerequisiteTasks = task.prerequisites?.allObjects as! [Task]
            dependentsTasks = task.dependents?.allObjects as! [Task]
            energyLevel = Int(task.energyLevel)
            splitCountStepper.value = Double(task.splitCount)
            if splitCountStepper.value != 1 {
                splitUnitTextField.text = task.splitUnit
            }
        } else {
            costTimePicker.countDownDuration = 25*60
            energyLevelStepper.value = 3
            titleTextField.becomeFirstResponder()
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
        updateRelatedTaskLabel()
        updateSplitCountTexts()
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
        costTimeLabel.text = String(format:"%d hour %d min", costMinutes/60, costMinutes%60)
    }
    
    func updateSplitCountTexts() {
        splitCountTextField.text = String(Int(splitCountStepper.value))
        costTimeTitleLabel.text = isSplitEnable ? "Estimated Unit Cost" : "Estimated Cost"
        updateTableView()
    }
    
    func updateProjectLabel() {
        projectLabel.text = isProjectSelected ? currentProject?.title : "None"
    }
    
    func updateRelatedTaskLabel() {
        prerequisitesLabel.text = getTaskListTitle(with: prerequisiteTasks)
        dependentsLabel.text = getTaskListTitle(with: dependentsTasks)
    }
    
    func getTaskListTitle(with taskList: [Task]) -> String {
        switch taskList.count {
        case 1:
            return taskList.first!.title!
        case 2...taskList.count + 2:
            return taskList.first!.title! + " ..."
        default:
            return "None"
        }
    }
    
    func updateTableView() {
        tableView.beginUpdates()
        tableView.endUpdates()
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
            updateTableView()
            
        case (dueDatePickerCellIndexPath.section, dueDatePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = false
            isDueDatePickerShown = !isDueDatePickerShown
            isDurationTimePickerShown = false
            updateTableView()
            
        case (costTimePickerCellIndexPath.section, costTimePickerCellIndexPath.row - 1):
            isDeferDatePickerShown = false
            isDueDatePickerShown = false
            isDurationTimePickerShown = !isDurationTimePickerShown
            updateTableView()
        
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Define Date Picker height
        switch (indexPath) {
        case deferDatePickerCellIndexPath:
            return isDeferDatePickerShown ? 216.0 : 0.0
        
        case dueDatePickerCellIndexPath:
            return isDueDatePickerShown ? 216.0 : 0.0
        
        case costTimePickerCellIndexPath:
            return isDurationTimePickerShown ? 216.0 : 0.0
        
        case splitUnitCellIndexPath:
            return isSplitEnable ? 44.0 : 0.0
            
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
            task?.costMinutes = Int32(costMinutes)
            task?.project = currentProject
            // TODO: Set subtract
            task?.removeFromPrerequisites(task!.prerequisites!)
            task?.addToPrerequisites(NSSet(array: prerequisiteTasks))
            task?.removeFromDependents(task!.dependents!)
            task?.addToDependents(NSSet(array: dependentsTasks))
            task?.energyLevel = Int16(energyLevel)
            task?.splitCount = Int32(splitCountStepper.value)
            if task?.splitCount != 1 {
                task?.splitUnit = splitUnitTextField.text
            }
            try? context.save()
        
        case "SelectProject":
            let selectProjectViewController = segue.destination as! SelectProjectTableViewController
            selectProjectViewController.selectedProject = currentProject
            prerequisiteTasks = []
            dependentsTasks = []
        
        case "SelectPrerequisiteTasks":
            let selectTaskViewController = segue.destination as! SelectTaskTableViewController
            var tasks = currentProject?.tasks as! Set<Task>
            for dependent in dependentsTasks {
                tasks.subtract(dependent.getAllDependents())
                tasks.remove(dependent)
            }
            if task != nil {
                tasks.remove(task!)
            }
            selectTaskViewController.tasks = Array(tasks)
            selectTaskViewController.selectedTasks = prerequisiteTasks
            selectTaskViewController.identifier = "SelectPrerequisiteTasks"
            
        case "SelectDependentTasks":
            let selectTaskViewController = segue.destination as! SelectTaskTableViewController
            var tasks = currentProject?.tasks as! Set<Task>
            for prerequisite in prerequisiteTasks {
                tasks.subtract(prerequisite.getAllPrerequisites())
                tasks.remove(prerequisite)
            }
            if task != nil {
                tasks.remove(task!)
            }
            selectTaskViewController.tasks = Array(tasks)
            selectTaskViewController.selectedTasks = dependentsTasks
            selectTaskViewController.identifier = "SelectDependentTasks"
        default:
            break
        }
    }

    @IBAction func unwindToAETask(segue: UIStoryboardSegue) {
        
    }
}
