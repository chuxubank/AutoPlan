//
//  AddEditProjectTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/17.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit

class AddEditProjectTableViewController: UITableViewController {
    
    let context = AppDelegate.viewContext
    var project: Project? = nil
    var currentColor: UIColor? = nil
    let colorCellIndexPath = IndexPath(row: 0, section: 1)
    let notesTextViewCellIndexPath = IndexPath(row: 0, section: 2)
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load data
        if let project = project {
            titleTextField.text = project.title
            notesTextView.text = project.notes
            currentColor = project.color as? UIColor
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDoneButtonState()
        updateColorCell()
    }
    
    func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }
    
    func updateColorCell() {
        let cell = tableView.cellForRow(at: colorCellIndexPath)
        cell?.imageView?.tintColor = currentColor
    }

    // MARK: - Table view
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case notesTextViewCellIndexPath:
            return 132.0
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case "projectDoneUnwind":
            if project == nil {
                project = Project(context: context)
            }
            project!.title = titleTextField.text ?? ""
            project?.notes = notesTextView.text ?? ""
            project?.color = currentColor
            try? context.save()
        case "SelectColor":
            let selectColorViewController = segue.destination as! SelectColorTableViewController
            selectColorViewController.selectedColor = currentColor
        default:
            break
        }
    }

    @IBAction func unwindToAEProject(segue: UIStoryboardSegue) {
        
    }
}
