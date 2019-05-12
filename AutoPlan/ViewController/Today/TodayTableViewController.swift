//
//  BoxTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/1.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import CoreData
import EventKitUI

class TodayTableViewController: UITableViewController, EKEventEditViewDelegate {
    
    let context = AppDelegate.viewContext
    
    var store = EKEventStore()
    var events = [EKEvent]()
    var nextAction: Task? = nil
    var unitCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestReminders()
        calculateNextAction()
        tableView.reloadData()
    }

    @objc func addButtonClicked(sender: UIBarButtonItem) {
        let eventEditViewController = EKEventEditViewController.init()
        eventEditViewController.eventStore = store
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .canceled:
            controller.cancelEditing()
        case .deleted:
            try? controller.eventStore.remove(controller.event!, span: .thisEvent, commit: true)
        case .saved:
            try? controller.eventStore.save(controller.event!, span: .thisEvent, commit: true)
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func requestReminders() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            store.requestAccess(to: .event, completion: {
                (accessGranted: Bool, error: Error?) in
                if accessGranted == true {
                    self.fetchEvents()
                }
            })
        case .authorized:
            fetchEvents()
        default:
            break
        }
    }
    
    func fetchEvents() {
        let startDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate!)
        let predicate: NSPredicate? = store.predicateForEvents(withStart: startDate!, end: endDate!, calendars: [store.defaultCalendarForNewEvents!])
        if let aPredicate = predicate {
            events = store.events(matching: aPredicate)
        }
    }
    
    func calculateNextAction() {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let predicate = NSPredicate(format: "isDone == false && deferDate < %@", Date() as NSDate)
        request.predicate = predicate
        var tasks = try! context.fetch(request)
        for task in tasks {
            if task.prerequisites?.count != 0 {
                tasks.remove(at: tasks.firstIndex(of: task)!)
            }
        }
        if tasks.count != 0 {
            let data = calculateLast7Days()
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents(in: calendar.timeZone, from: Date())
            let now = (dateComponents.hour! * 60 + dateComponents.minute!) / 5
            tasks.sort(by: {$0.energyLevel > $1.energyLevel})
            var taskEnergy = Array(repeating: 0, count: tasks.count)
            for i in 0..<tasks.count {
                taskEnergy[i] = Int(tasks[i].energyLevel)
            }
            let i = lower_bound(target: data[now], arr: taskEnergy)
            nextAction = tasks[i]
        } else {
            nextAction = nil
        }
    }
    
    func lower_bound(target: Int, arr: [Int]) -> Int
    {
        var low = 0
        var high = arr.count - 1
        var mid = (low + high) >> 1
        
        while low <= high {
            let val = arr[mid]
            if target == val {
                return mid
            } else if target < val {
                high = mid - 1
            } else {
                low = mid + 1
            }
            mid = (low + high) >> 1
        }
        return low
    }
    
    func calculateLast7Days() -> [Int] {
        let request: NSFetchRequest<Action> = Action.fetchRequest()
        let actions = try! context.fetch(request)
        var data = Array(repeating: 0, count: 24*60/5)
        var count = Array(repeating: 0, count: 24*60/5)
        for action in actions {
            if action.doneTime! < Date(), action.doneTime! > Calendar.current.date(byAdding: .day, value: -7, to: Date())! {
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents(in: calendar.timeZone, from: action.doneTime!)
                let end = (dateComponents.hour! * 60 + dateComponents.minute!) / 5
                let begin = end - Int(action.costMinutes/5)
                for i in begin...end {
                    data[i] += Int(action.energyLevel)
                    count[i] += 1
                }
            }
        }
        for i in 0...24*60/5-1 {
            if count[i] != 0 {
                data[i] /= count[i]
            }
        }
        return data
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Events"
        case 1:
            return "Next Action"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return events.count
        } else {
            return nextAction == nil ? 0 : 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
            cell.update(with: events[indexPath.row])
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NextActionCell", for: indexPath) as! NextActionTableViewCell
            cell.update(with: nextAction!, unitCount: unitCount)
            return cell
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            try? store.remove(events.remove(at: indexPath.row), span: .thisEvent, commit: true)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let eventEditViewController = EKEventEditViewController.init()
            eventEditViewController.event = events[indexPath.row]
            eventEditViewController.eventStore = store
            eventEditViewController.editViewDelegate = self
            present(eventEditViewController, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EditTask":
            let navController = segue.destination as! UINavigationController
            let addEditTaskTableViewController = navController.topViewController as! AddEditTaskTableViewController
            addEditTaskTableViewController.task = nextAction
        default:
            break
        }
    }

}
