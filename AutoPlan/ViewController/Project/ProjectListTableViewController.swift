//
//  ProjectTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/17.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import CoreData

class ProjectListTableViewController: UITableViewController {
    
    let context = AppDelegate.viewContext
    var projects = [Project]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProjects()
        tableView.reloadData()
    }
    
    func updateProjects() {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        projects = try! context.fetch(request)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath)
        
        let project = projects[indexPath.row]
        cell.textLabel?.text = project.title
        cell.detailTextLabel?.text = project.notes
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(projects.remove(at: indexPath.row))
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
        if segue.identifier == "ShowProjectDetail" {
            let indexPath = tableView.indexPath(for: (sender as! UITableViewCell))!
            let project = projects[indexPath.row]
            let navController = segue.destination as! UINavigationController
            let addEditProjectTableViewController = navController.topViewController as! AddEditProjectTableViewController
            addEditProjectTableViewController.project = project
        }
        
        if segue.identifier == "ShowTaskList" {
            let indexPath = tableView.indexPathForSelectedRow!
            let project = projects[indexPath.row]
            let taskListTableViewController = segue.destination as! TaskListTableViewController
            taskListTableViewController.sourceProject = project
        }
    }

    @IBAction func unwindToProject(segue: UIStoryboardSegue) {
        
    }
}
