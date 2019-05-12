//
//  ActionListTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/9.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import CoreData

class ActionListTableViewController: UITableViewController {

    let context = AppDelegate.viewContext
    var date: Date? = nil
    var actions = [Action]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        self.title = dateFormatter.string(from: date!)
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateActions()
    }
    
    func updateActions() {
        let request: NSFetchRequest<Action> = Action.fetchRequest()
        let startTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date!)
        let endTime = Calendar.current.date(byAdding: .day, value: 1, to: startTime!)
        request.predicate = NSPredicate(format: "doneTime > %@ && doneTime < %@", startTime! as NSDate, endTime! as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "doneTime", ascending: false)]
        actions = try! context.fetch(request)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Actions"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)
        let action = actions[indexPath.row]
        let appendText = action.task?.splitCount == 1 ? "" :
            " \(action.doneUnitCount) " + action.task!.splitUnit!
        cell.textLabel?.text = action.task!.title! + appendText
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .none
        cell.detailTextLabel?.text = dateFormatter.string(from: action.doneTime!)
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(actions.remove(at: indexPath.row))
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
        switch segue.identifier {
        case "EditAction":
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! AddEditActionTableViewController
            vc.action = actions[tableView.indexPathForSelectedRow!.row]
        default:
            break
        }
    }

}
