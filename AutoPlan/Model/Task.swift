//
//  Task.swift
//  AutoPlan
//
//  Created by Misaka on 2019/5/4.
//  Copyright © 2019 Misaka. All rights reserved.
//

import Foundation

extension Task {
    func getAllPrerequisites() -> Set<Task> {
        let selfPrerequisites = self.prerequisites as! Set<Task>
        if selfPrerequisites.isEmpty {
            return []
        } else {
            var childPrerequisites = Set<Task>()
            for prerequisite in selfPrerequisites {
                for task in prerequisite.getAllPrerequisites() {
                    childPrerequisites.insert(task)
                }
            }
            return childPrerequisites.union(selfPrerequisites)
        }
    }
    
    func getAllDependents() -> Set<Task> {
        let selfDependents = self.dependents as! Set<Task>
        if selfDependents.isEmpty {
            return []
        } else {
            var childDependents = Set<Task>()
            for dependent in selfDependents {
                for task in dependent.getAllPrerequisites() {
                    childDependents.insert(task)
                }
            }
            return childDependents.union(selfDependents)
        }
    }
}
