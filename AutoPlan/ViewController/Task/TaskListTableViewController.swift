//
//  TodayTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/2.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class TaskListTableViewController: UITableViewController, TaskCellDelegate {
    
    let context = AppDelegate.viewContext
    var store = EKEventStore()
    var tasks = [Task]()
    var sourceProject: Project? {
        didSet {
            self.title = sourceProject?.title
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTasks()
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        refreshTasks()
    }
    
    func requestReminders() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .notDetermined:
            store.requestAccess(to: .reminder, completion: {
                (accessGranted: Bool, error: Error?) in
                if accessGranted == true {
                    self.fetchReminders()
                }
            })
        case .authorized:
            fetchReminders()
        default:
            break
        }
    }
    
    func fetchReminders() {
        let predicate: NSPredicate? = store.predicateForReminders(in: [store.defaultCalendarForNewReminders()!])
        if let aPredicate = predicate {
            // async fetch
            store.fetchReminders(matching: aPredicate, completion: {(_ reminders: [EKReminder]?) -> Void in
                for reminder: EKReminder? in reminders ?? [EKReminder?]() {
                    if(!reminder!.isCompleted) {
                        let task = Task(context: self.context)
                        task.title = reminder?.title
                        task.notes = reminder?.notes
                        task.deferDate = reminder?.startDateComponents?.date
                        task.dueDate = reminder?.dueDateComponents?.date
                        task.createTime = Date()
                        task.splitCount = 1
                        task.costMinutes = 5
                        task.energyLevel = 3
                        task.isDone = false
                        task.project = self.sourceProject
                        self.tasks.insert(task, at: 0)
                        try? self.store.remove(reminder!, commit: true)
                    }
                }
                try? self.context.save()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            })
        }
    }
    
    func refreshTasks() {
        requestReminders()
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "project == %@ && isDone == false", sourceProject ?? 0)
        request.predicate = predicate
        tasks = try! context.fetch(request)
        tasks = tasks.sorted(by: {$0.createTime! > $1.createTime!})
        tableView.reloadData()
    }

    func checkMarkTapped(sender: TaskTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let task = tasks[indexPath.row]
            if task.splitCount == 1 { 
                if task.isDone {
                    task.isDone = false
                    // TODO: Use NSBatchDeleteRequest to delete actions
                    for action in task.actions! {
                        context.delete(action as! NSManagedObject)
                    }
                } else {
                    task.isDone = true
                    task.removeFromDependents(task.dependents!)
                    let action = Action(context: context)
                    action.costMinutes = task.costMinutes
                    action.doneTime = Date()
                    action.doneUnitCount = 1
                    action.energyLevel = task.energyLevel
                    action.task = task
                }
                try? context.save()
            }
            else {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let navViewController = sb.instantiateViewController(withIdentifier: "navAEAction") as! UINavigationController
                let vc = navViewController.topViewController as? AddEditActionTableViewController
                vc?.sourceTask = task
                present(navViewController, animated: true, completion: nil)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tasks.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        let task = tasks[indexPath.row]
        cell.update(with: task)
        cell.delegate = self
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete model first
            context.delete(tasks.remove(at: indexPath.row))
            tableView.deleteRows(at: [indexPath], with: .fade)
            try? context.save()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditTask" {
            let indexPath = tableView.indexPathForSelectedRow!
            let task = tasks[indexPath.row]
            let navController = segue.destination as! UINavigationController
            let addEditTaskTableViewController = navController.topViewController as! AddEditTaskTableViewController
            addEditTaskTableViewController.task = task
        }
        
        if segue.identifier == "AddTask" {
            let navController = segue.destination as! UINavigationController
            let addEditTaskTableViewController = navController.topViewController as! AddEditTaskTableViewController
            addEditTaskTableViewController.currentProject = sourceProject
        }
    }

    @IBAction func unwindToTaskList(segue: UIStoryboardSegue) {
        
    }
}
