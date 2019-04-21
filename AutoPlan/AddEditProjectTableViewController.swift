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
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    let notesTextViewCellIndexPath = IndexPath(row: 0, section: 1)
    
    func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load data
        if let project = project {
            titleTextField.text = project.title
            notesTextView.text = project.notes
        }
        
        updateDoneButtonState()
    }

    // MARK: - Table view
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case notesTextViewCellIndexPath:
            return 180.0
        default:
            return 44.0
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "projectDoneUnwind" else { return }
        
        if project == nil {
            project = Project(context: context)
        }
        
        project!.title = titleTextField.text ?? ""
        project?.notes = notesTextView.text ?? ""
    }

}
