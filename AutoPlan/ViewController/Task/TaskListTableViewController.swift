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
    var sourceProject: Project? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if sourceProject == nil {
            checkReminderAuthorizationStatus()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTasks()
        tableView.reloadData()
        if sourceProject == nil {
            self.title = "Inbox"
        } else {
            self.title = sourceProject!.title
        }
    }
    
    func checkMarkTapped(sender: TaskTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            let task = tasks[indexPath.row]
            if task.splitCount == 1 {
                task.isDone = !task.isDone
            }
            else {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let navViewController = sb.instantiateViewController(withIdentifier: "navAEAction") as! UINavigationController
                let vc = navViewController.topViewController as? AddEditActionTableViewController
                vc?.task = task
                present(navViewController, animated: true, completion: nil)
            }
            tasks[indexPath.row] = task
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func checkReminderAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        switch status {
        case .notDetermined:
            requestAccessToReminder()
        case .authorized:
            loadReminders()
        default:
            break
        }
    }
    
    func requestAccessToReminder() {
        store.requestAccess(to: EKEntityType.reminder, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    self.loadReminders()
                    self.updateTasks()
                })
            }
        })
    }
    
    func loadReminders() {
        let predicate: NSPredicate? = store.predicateForReminders(in: [store.defaultCalendarForNewReminders()!])
        if let aPredicate = predicate {
            store.fetchReminders(matching: aPredicate, completion: {(_ reminders: [EKReminder]?) -> Void in
                for reminder: EKReminder? in reminders ?? [EKReminder?]() {
                    if(!reminder!.isCompleted) {
                        let task = Task(context: self.context)
                        task.title = reminder?.title
                        task.notes = reminder?.notes
                        task.dueDate = reminder?.dueDateComponents?.date
                        try? self.store.remove(reminder!, commit: true)
                        try? self.context.save()
                    }
                }
            })
        }
    }
    
    func updateTasks() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "project == %@", sourceProject ?? 0)
        request.predicate = predicate
        tasks = try! context.fetch(request)
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
