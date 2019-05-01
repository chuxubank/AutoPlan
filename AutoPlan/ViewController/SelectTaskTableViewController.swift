//
//  SelectTaskTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/1.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import CoreData

class SelectTaskTableViewController: UITableViewController {

    let context = AppDelegate.viewContext
    var sourceProject: Project? = nil
    var tasks: [Task] {
        return sourceProject?.tasks?.allObjects as! [Task]
    }
    var selectedTasks = [Task]()
    var identifier = ""
    
    override func viewWillDisappear(_ animated: Bool) {
        if isMovingFromParent {
            let navController = parent as! UINavigationController
            let addEditTaskTableViewController = navController.topViewController as! AddEditTaskTableViewController
            for i in 0..<tasks.count {
                let cell = tableView.cellForRow(at: [0,i])
                if cell?.accessoryType == .checkmark {
                    selectedTasks.append(tasks[i])
                }
            }
            switch identifier {
            case "SelectDependentTasks":
                addEditTaskTableViewController.dependentsTasks = selectedTasks
            case "SelectPrerequisiteTasks":
                addEditTaskTableViewController.prerequisiteTasks = selectedTasks
            default:
                break
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if selectedTasks.contains(task) {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        let isChecked = cell!.accessoryType == .checkmark
        cell!.accessoryType = isChecked ? .none : .checkmark
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
