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
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateDoneButtonState()
    }
    
    func updateDoneButtonState() {
        let text = titleTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDoneButtonState()
    }

    // MARK: - Table view
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Define Date Picker height
        switch (indexPath.section, indexPath.row) {
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
        project?.notes = noteTextView.text ?? ""
    }

}
