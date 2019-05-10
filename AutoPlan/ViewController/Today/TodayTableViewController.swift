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
    
    var store = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkEventAuthorizationStatus()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked(sender:)))
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
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    func checkEventAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .notDetermined:
            requestAccessToEvent()
        case .authorized:
            break
        default:
            break
        }
    }
    
    func requestAccessToEvent() {
        store.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {
                DispatchQueue.main.async(execute: {
                    // ...
                })
            }
        })
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
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
