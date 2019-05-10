//
//  AllActionListByDayTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/8.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import CoreData

class DayListTableViewController: UITableViewController {

    let context = AppDelegate.viewContext
    let dateFormatter = DateFormatter()
    var actions = [Action]()
    var data = [Date:Int]()
    var dateArray = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        dateFormatter.dateStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request: NSFetchRequest<Action> = Action.fetchRequest()
        actions = try! context.fetch(request)
        data.removeAll()
        
        for action in actions {
            var haveSameDay = false
            for date in data.keys {
                if Calendar.current.isDate(date, inSameDayAs: action.doneTime!) {
                    haveSameDay = true
                    data[date] = data[date]! + 1
                }
            }
            if !haveSameDay {
                data[action.doneTime!] = 1
            }
        }
        
        dateArray = data.keys.sorted(by: >)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Action Count"
        } else {
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)

        cell.textLabel?.text = String(format: "%d", data[dateArray[indexPath.row]]!)
        cell.detailTextLabel?.text = dateFormatter.string(from: dateArray[indexPath.row])

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let date = dateArray[indexPath.row]
            for action in actions {
                if Calendar.current.isDate(date, inSameDayAs: action.doneTime!) {
                    context.delete(action)
                }
            }
            try? context.save()
            tableView.deleteRows(at: [indexPath], with: .fade)
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
        case "ShowActionList":
            let vc = segue.destination as! ActionListTableViewController
            vc.date = dateArray[tableView.indexPathForSelectedRow!.row]
        default:
            break
        }
    }

}
