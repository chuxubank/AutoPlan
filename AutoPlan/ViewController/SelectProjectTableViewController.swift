//
//  SelectProjectTableViewController.swift
//  AutoPlan
//
//  Created by Misaka on 2019/4/20.
//  Copyright © 2019 Misaka. All rights reserved.
//

import UIKit
import CoreData

class SelectProjectTableViewController: UITableViewController {
    
    let context = AppDelegate.viewContext
    var projects = [Project]()
    var selectedProject: Project? = nil
    var noneProject: Project? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProjects()
        tableView.reloadData()
        if selectedProject == nil {
            selectedProject = noneProject
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let noneProject = noneProject {
            context.delete(noneProject)
        }
    }
    
    func updateProjects() {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        projects = try! context.fetch(request)
        noneProject = Project(context: context)
        noneProject?.title = "None"
        projects.insert(noneProject!, at: 0)
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
        if project == selectedProject {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .checkmark
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "projectSelectedUnwind" {
            let addEditTaskViewController = segue.destination as! AddEditTaskTableViewController
            let row = tableView.indexPathForSelectedRow!.row
            selectedProject = row == 0 ? nil : projects[row]
            addEditTaskViewController.currentProject = selectedProject
        }
    }

}
