//
//  AddEditActionTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/6.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class AddEditActionTableViewController: UITableViewController {

    let context = AppDelegate.viewContext
    let dateFormatter = DateFormatter()
    
    var action: Action? = nil
    var sourceTask: Task? = nil
    var doneTime = Date() {
        didSet {
            doneTimeLabel.text =
                dateFormatter.string(from: doneTime)
        }
    }
    var costMinutes = 0 {
        didSet {
            costLabel.text =
                String(format:"%d hour %d min", costMinutes/60, costMinutes%60)
        }
    }
    var energyLevel = 3 {
        didSet {
            energyLevelLabel.text = "\(energyLevel)"
            energyLevelStepper.value = Double(energyLevel)
        }
    }
    var doneUnitCount = 0 {
        didSet {
            doneUnitCountTextField.text =
                doneUnitCount == 0 ? "" : "\(doneUnitCount)"
            
            if doneUnitCount > leftUnitCount {
                doneUnitCount = leftUnitCount
                doneUnitCountTextField.text = "\(doneUnitCount)"
            }
        }
    }
    var leftUnitCount: Int {
        return Int(sourceTask!.splitCount) - sourceTask!.doneSplitCount
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        if action == nil {
            action = Action(context: context)
        }
        action?.doneTime = doneTime
        action?.costMinutes = Int32(costMinutes)
        action?.energyLevel = Int16(energyLevel)
        action?.doneUnitCount = Int32(doneUnitCount)
        action?.task = sourceTask
        try? context.save()
        if leftUnitCount == 0 {
            sourceTask?.isDone = true
        }
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var doneTimeLabel: PickerLabel!
    @IBOutlet weak var costLabel: PickerLabel!
    @IBOutlet weak var energyLevelLabel: UILabel!
    @IBOutlet weak var energyLevelStepper: UIStepper!
    @IBAction func energySetpperValueChanged(_ sender: UIStepper) {
        energyLevel = Int(energyLevelStepper.value)
    }
    @IBOutlet weak var doneUnitCountTextField: UITextField!
    @IBAction func doneUnitCountEditingChanged(_ sender: UITextField) {
        doneUnitCount = Int(doneUnitCountTextField.text!) ?? 0
        updateDoneButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDoneButtonState()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        if let action = action {
            sourceTask = action.task
            doneTime = action.doneTime ?? Date()
            costMinutes = Int(action.costMinutes)
            energyLevel = Int(action.energyLevel)
            doneUnitCount = Int(action.doneUnitCount)
        } else {
            doneTime = Date()
            costMinutes = Int(sourceTask!.costMinutes)
            energyLevel = Int(sourceTask!.energyLevel)
            doneUnitCountTextField.placeholder = sourceTask!.splitUnit
            doneUnitCountTextField.becomeFirstResponder()
        }
        self.title = sourceTask?.title
    }
    
    @objc func doneDateTimePickerValueChanged(sender: UIDatePicker) {
        doneTime = sender.date
    }
    
    @objc func costTimePickerValueChanged(sender: UIDatePicker) {
        costMinutes = Int(sender.countDownDuration/60)
    }
    
    func updateDoneButtonState() {
        let text = doneUnitCountTextField.text ?? ""
        doneButton.isEnabled = !text.isEmpty
    }
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let datePicker = doneTimeLabel.inputView as? UIDatePicker
            datePicker?.datePickerMode = .dateAndTime
            datePicker?.addTarget(self, action: #selector(doneDateTimePickerValueChanged(sender:)), for: .valueChanged)
            doneTimeLabel.becomeFirstResponder()
            datePicker?.setDate(doneTime, animated: true)
        case 1:
            let datePicker = costLabel.inputView as? UIDatePicker
            datePicker?.datePickerMode = .countDownTimer
            datePicker?.minuteInterval = 5
            datePicker?.addTarget(self, action: #selector(costTimePickerValueChanged(sender:)), for: .valueChanged)
            costLabel.becomeFirstResponder()
            datePicker?.countDownDuration = TimeInterval(costMinutes*60)
        case 3:
            doneUnitCountTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return String(format: "There are %d %@ left in %@", leftUnitCount, sourceTask!.splitUnit ?? "", sourceTask!.title!)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
